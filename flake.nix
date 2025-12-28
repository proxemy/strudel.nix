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
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nodejs-slim
        pnpm
      ];
      shellHook = ''
        pnpm --version
      '';
    };
  };
}
