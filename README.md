# strudel.nix

A strudel.cc application wrapper in nix.

Work in progress! Currently only runs on x86-64_linux.

# Usage

Use `nix run github:proxemy/strudel.nix` to build, launch and open a new
strudel.cc tab in your browser.

`nix build` builds the project and it's dependencies in the `result` directory.

`nix develop` only loads the project dependendencies like `pnpm` into the local
environment. Since the sources of strudel.cc are stored immutably in the
nix-store you cannot work on them, only interact with the project via eg. `pnpm`.

# License

AGPLv3, same as strudel.cc, [see LICENSE](https://codeberg.org/uzu/strudel/src/branch/main/LICENSE).
