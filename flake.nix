{
  description = "A strudel.cc application wrapper.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    strudel = {
      url = "https://codeberg.org/uzu/strudel";
      type = "git";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      strudel,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      pnpm_deps = pkgs.fetchPnpmDeps {
        pname = "strudel_pnpm_deps";
        src = strudel;
        fetcherVersion = 3;
        hash = "sha256-UncT0yFpdvajXy/OQHKl8pnQQB8J7VstDjwCuDSCkBA=";
      };

      project_deps = with pkgs; [
        nodejs
        pnpmConfigHook
        pnpm
      ];
    in
    {
      packages.${system}.default = pkgs.stdenvNoCC.mkDerivation {
        name = "strudel.nix";
        src = strudel;
        nativeBuildInputs = project_deps;
        pnpmDeps = pnpm_deps;
        buildPhase = ''
          pnpm install
          pnpm run build
        '';
        installPhase =
          let
            targets = "{node_modules,website,packages,tools,examples}";
          in
          ''
            mkdir $out
            cp --recursive ${targets} $out

            # Disable the 'prestart' script, since it launches 'jsdoc', which
            # requires mutable runtime access but is implied in 'build' anyway.
            # Replace the 'start' script with 'preview'.
            # 'start' launches 'astro dev' which also requires mutable access.
            ${pkgs.jq}/bin/jq '
              .scripts.prestart = "" |
              .scripts.start = "pnpm preview"
            ' package.json > $out/package.json
          '';
      };

      apps.${system}.default =
        let
          strudel_wrapper = pkgs.writeShellApplication {
            name = "strudel_wrapper";
            runtimeInputs = project_deps ++ [ self ];
            text = ''
              pushd ${self.outputs.packages.${system}.default}
              pnpm run start -- --open
            '';
          };
        in
        {
          meta.description = "Launch and open strudel.cc in your browser.";
          type = "app";
          program = "${strudel_wrapper}/bin/strudel_wrapper";
        };

      devShells.${system}.default = pkgs.mkShell {
        packages = project_deps;
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
