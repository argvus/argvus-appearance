# Development

Argvus Appearance contains shared themes and appearance integration for Argvus.

## Requirements

This repository is config-only. Local validation requires `make`, a POSIX
shell and standard POSIX install tools.

On Arch Linux, the package recipe lives at `packaging/arch/PKGBUILD`.

## Commands

Validate the expected asset layout:

```sh
make validate
python tools/test-theme-switch.py
```

Validate installation into a staging directory:

```sh
make DESTDIR=/tmp/argvus-appearance-pkg PREFIX=/usr install
```

## Package Contents

The Arch package installs:

```text
/usr/share/argvus/appearance/{config,sh,docs}/
/usr/share/licenses/argvus-appearance/LICENSE
```

Wallpapers and fonts live in the `argvus-wallpapers` and `argvus-fonts`
packages.

The package is architecture-independent, so `makepkg` produces a file named
`argvus-appearance-X.Y.Z-1-any.pkg.tar.zst`. It is still published under
`argvus/packages/public/arch/x86_64/`, matching the repository layout used by
the Argvus package server.

## Release Flow

1. Tag `vX.Y.Z` and push the tag.
2. Confirm the package workflow builds `argvus-appearance-X.Y.Z-1-any.pkg.tar.zst` and its `.sig`.
3. Confirm the workflow publishes both files to `argvus/packages` under `public/arch/x86_64/` and updates the Arch repository database.

The project does not create GitHub Releases for package distribution. The built
`.pkg.tar.zst` and `.sig` are kept as GitHub Actions artifacts for one day only;
the permanent package copies live in `argvus/packages`.
