# strudel.nix

A strudel.cc application wrapper in nix.

Work in progress! Currently only runs on x86-64_linux and relies on xdg-open to
open the website.

# Usage

`nix build` builds and bundles the JS dependencies.

`nix develop` only loads the project dependendencies like `pnpm` into the
environment. Since the sources of strudel.cc are stored immutable in the nix-store
you cannot develop the project itself.

`nix run` starts a local strudel.cc server and opens it in your browser. WIP!

# License

AGPLv3, same as upstream strudel.cc, [see LICENSE](https://codeberg.org/uzu/strudel/src/branch/main/LICENSE).
