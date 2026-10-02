---
title: Fonts and icons
description: Configure the fonts and icon themes used by ARGVUS.
---

`argvus-fonts` installs the bundled fonts under `/usr/share/fonts/`; `argvus-icons` installs the ARGVUS icon themes. `argvus-appearance` and the Control Center connect these assets to the desktop theme.

## Primary font

The ARGVUS default primary font is **IBM Plex Mono**, with the `Regular` style. It is the default family used by the font targets exposed in Control Center. The bundled `argvus-fonts` package provides IBM Plex Mono and the supporting icon/terminal families used by the desktop.

Open **Control Center → Fonts** to configure individual targets:

- taskbar;
- telemetry/system information;
- Control Panel;
- ARGVUS system interface;
- applications;
- terminal;
- browser.

The default sizes are target-specific: taskbar, system and terminal use `13`; telemetry and Control Panel use `14`; applications use `12`; and browser uses `10`. These defaults can be restored from the Fonts page.

Use the font controls in the Control Center. Font preferences are canonical in `config.json`, at `fonts.targets.<target>` for family, style and size plus `fonts.rendering` for antialiasing, hinting, subpixel order and DPI. The Control Center persists them through `argvus-config`; it does not write consumer files itself. `argvus-config` then projects `data/generated/fonts.conf` and rewrites the delimited font block inside `data/waybar/argvus-taskbar.css` and `data/waybar/argvus-widget-telemetry.css`, so font edits outside those blocks survive a font change. Terminal and GTK fontconfig rules remain native adapter targets. The package runs the font cache update during installation.
