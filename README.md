# strudel.nix

A strudel.cc application wrapper in nix.

Work in progress! Currently only runs on x86-64_linux.

# Usage

`nix build` builds the project and it's dependencies in the `result` directory.

`nix develop` only loads the project dependendencies like `pnpm` into the local
environment. Since the sources of strudel.cc are stored immutably in the
nix-store you cannot work on them, only interact with the project via eg. `pnpm`.

`nix run` starts a local `node` server and opens strudel.cc in your browser.

# License

AGPLv3, same as upstream strudel.cc, [see LICENSE](https://codeberg.org/uzu/strudel/src/branch/main/LICENSE).
