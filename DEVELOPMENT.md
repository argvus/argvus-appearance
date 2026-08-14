# Development

Argvus Appearance contains shared wallpapers and bundled fonts for Argvus.

## Requirements

This repository is asset-only. Local validation requires `make` and standard
POSIX install tools.

On Arch Linux, the package recipe lives at `packaging/arch/PKGBUILD`.

## Commands

Validate the expected asset layout:

```sh
test -f usr/share/backgrounds/argvus/default.png
test -f usr/share/backgrounds/argvus/argvus-dark-silver.png
test -f usr/share/backgrounds/argvus/argvus-light.png
test -f usr/share/backgrounds/argvus/argvus-slate.png
test -f usr/share/fonts/TerminusTTF.ttf
test -f "usr/share/fonts/Font Awesome 7 Free-Solid-900.otf"
```

Validate installation into a staging directory:

```sh
make DESTDIR=/tmp/argvus-appearance-pkg PREFIX=/usr install
```

## Package Contents

The Arch package installs:

```text
/usr/share/backgrounds/argvus/
/usr/share/fonts/
/usr/share/licenses/argvus-appearance/LICENSE
```

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
