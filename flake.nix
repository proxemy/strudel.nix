{
  description = ''
    A strudel.cc application wrapper for hermetic
    reproduction of tidal cycles music projects.
  '';

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
        installPhase = ''
          mkdir $out
          cp --recursive * $out

          # Disable the 'prestart' script, since is launches 'jsdoc', which
          # requires mutable runtime access but is implied in 'build' anyway.
          # Replace the 'start' script with 'preview'.
          # 'start' launches 'astro dev' wich also requires mutable access.
          ${pkgs.jq}/bin/jq '
            .scripts.prestart = "" |
            .scripts.start = "pnpm preview"
          ' package.json > $out/package.json
        '';
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = project_deps ++ [ self.outputs.packages.${system}.default ];
        pnpmDeps = pnpm_deps;
      };

      apps.${system}.default = {
        type = "app";
        program = "pnpm start";
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
