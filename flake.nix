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
