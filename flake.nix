{
  description = ''
    A strudel.cc application wrapper for hermenetic
    reproduction of tidal cycles music projects.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    strudel = {
      url = "https://codeberg.org/uzu/strudel";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, strudel }: {
  };
}
