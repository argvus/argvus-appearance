# Argvus Appearance

Argvus Appearance contains shared visual assets for the Argvus Desktop
Environment.

It currently ships:

- Argvus wallpapers under `/usr/share/backgrounds/argvus`
- Argvus bundled fonts under `/usr/share/fonts`

Keeping these assets in a separate package avoids duplicating wallpapers and
fonts inside the main `argvus` desktop configuration package.

## Layout

```text
usr/
  share/
    backgrounds/
      argvus/
    fonts/
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
