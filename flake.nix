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

  outputs = { self, nixpkgs, strudel }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    strudel_pnpm_deps = pkgs.fetchPnpmDeps {
      pname = "strudel_pnpm_deps";
      src = strudel;
      fetcherVersion = 3;
      hash = "sha256-v/2txWPJNAAv+cU4E5TnaRwFdoUBaQLMu88FuRlNxO8=";
    };
  in
  {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      name = "strudel.nix";
      src = strudel;
      nativeBuildInputs = with pkgs; [
        nodejs
        pnpmConfigHook
        pnpm
      ];
      pnpmDeps = strudel_pnpm_deps;
      buildPhase = "pnpm run build";
      # Maybe not the entire repository needs to copied over
      # but this is how the project is structured atm.
      installPhase = "mkdir $out; cp --recursive * $out";
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nodejs-slim
        pnpm
      ];
      shellHook = ''
        pnpm --version
      '';
    };

    formatter.${system} = pkgs.nixfmt-rfc-style;
  };
}
