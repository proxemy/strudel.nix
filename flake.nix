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
        hash = "sha256-v/2txWPJNAAv+cU4E5TnaRwFdoUBaQLMu88FuRlNxO8=";
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
            mkdir --parent $out/${targets}
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
          launch_wrapper = pkgs.writeShellApplication {
            name = "strudel_launch_wrapper";
            runtimeInputs = project_deps;
            text = ''
              pushd ${self.packages.${system}.default}
              exec 9< <(pnpm start &)
              while read -r <&9 node_stdout; do
                echo "$node_stdout"
                if [[ "$node_stdout" =~ "://localhost:" ]]; then
                  url=$(echo "$node_stdout" | grep -oP "http://localhost:\d+")
                  open "$url"
                  break
                fi
              done
            '';
          };
        in
        {
          type = "app";
          program = "${launch_wrapper}/bin/strudel_launch_wrapper";
        };

      devShells.${system}.default = pkgs.mkShell {
        packages = project_deps;
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
