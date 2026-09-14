# Argvus Appearance

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

Arch packaging is owned by this repository through `packaging/arch/PKGBUILD`.

## Release Flow

Tag pushes build a signed Arch package and publish it to the shared
`argvus/packages` repository. GitHub Releases are not used for package
distribution.

## Related Repositories

- https://github.com/argvus/argvus
- https://github.com/argvus/packages
