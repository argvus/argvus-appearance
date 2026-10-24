# Argvus Appearance

<div align="center">

[![CI](https://github.com/argvus/argvus-appearance/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/argvus/argvus-appearance/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/argvus/argvus-appearance)](./LICENSE)
[![Language: Lua](https://img.shields.io/badge/Lua-2C2D72?logo=lua&logoColor=white)](https://www.lua.org/)
[![Platform: Arch Linux | Wayland](https://img.shields.io/badge/platform-Arch%20Linux%20%7C%20Wayland-1793D1?logo=archlinux&logoColor=white)](https://archlinux.org/)
[![Pull requests](https://img.shields.io/github/issues-pr/argvus/argvus-appearance)](https://github.com/argvus/argvus-appearance/pulls)
[![Issues](https://img.shields.io/github/issues/argvus/argvus-appearance)](https://github.com/argvus/argvus-appearance/issues)
[![Last commit](https://img.shields.io/github/last-commit/argvus/argvus-appearance)](https://github.com/argvus/argvus-appearance/commits/main)
[![Docs](https://img.shields.io/badge/docs-project-blue)](./docs/)

</div>

Argvus Appearance contains shared appearance configuration for the Argvus
Desktop Environment.

It currently ships:

- GTK / Qt theme integration under `/usr/share/argvus/appearance/config/gtk-3.0`,
  `/usr/share/argvus/appearance/config/gtk-4.0` and `/usr/share/argvus/appearance/config/qt6ct`
- Hyprland appearance integration under `/usr/share/argvus/appearance/config/hypr`
- Toggle, accent and brightness scripts under `/usr/share/argvus/appearance/sh`

Wallpapers and fonts are provided by the separate `argvus-wallpapers` and
`argvus-fonts` packages.

## Layout

```text
src/usr/share/argvus/appearance/
  config/{gtk-3.0,gtk-4.0,qt6ct,hypr,waybar}/
  sh/
  docs/
```

## Installation

```sh
make install
```

Use `DESTDIR` for packaging:

```sh
make DESTDIR="$pkgdir" PREFIX=/usr install
```

Arch packaging is owned by this repository through the remote and local recipes in
`packaging/arch/{ci,local}/PKGBUILD`, with shared helpers in
`packaging/arch/common/`.

## Release Flow

Tag pushes build a signed Arch package and publish it to the shared
`argvus/packages` repository. GitHub Releases are not used for package
distribution.

## Related Repositories

- https://github.com/argvus/argvus
- https://github.com/argvus/packages

## Contributing and policies

- [CONTRIBUTING.md](https://github.com/argvus/.github/blob/main/CONTRIBUTING.md) — contribution workflow
- [SECURITY.md](https://github.com/argvus/.github/blob/main/SECURITY.md) — private vulnerability reports
- [Code of Conduct](https://github.com/argvus/.github/blob/main/policies/CODE_OF_CONDUCT.md) — community standards
- [AI usage policy](https://github.com/argvus/.github/blob/main/policies/IA_USAGE.md) — rules for AI-assisted contributions
