{
  description = ''
    A strudel.cc application wrapper for hermenetic
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
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "strudel.nix";
        src = strudel;
        nativeBuildInputs = project_deps;
        pnpmDeps = pnpm_deps;
        buildPhase = "pnpm run build";
        # Maybe not the entire repository needs to copied over.
        installPhase = "mkdir $out; cp --recursive * $out";
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = project_deps;
        shellHook = "pnpm --version";
      };

      apps.${system}.default = {
        type = "app";
        program = "pnpm start";
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
