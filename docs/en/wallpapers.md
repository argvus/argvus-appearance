---
title: Wallpapers
description: Use built-in and custom ARGVUS wallpapers.
---

Built-in JPEG XL wallpapers are installed by `argvus-wallpapers` under `/usr/share/backgrounds/argvus/`. In **Control Center → Appearance → Wallpapers**, they are organized as `Abstract` or `Landscape`, then by `Dark` or `Light`. The root `argvus-dark.jxl` and `argvus-light.jxl` files appear under the abstract fallback groups. Theme switching uses only the abstract files in `abstract/dark` and `abstract/light`; landscape files are optional manual choices. Press `SUPER + Y` to open this Control Center screen directly. The first entry also accepts a custom image from HOME; the selected file becomes the user's custom wallpaper state.

The first entry opens a file chooser for a custom image. A selected custom wallpaper is stored as `/appearance/wallpaper` together with `/appearance/wallpaper_custom` in the canonical configuration, and `argvus config` projects it into the Hyprland wallpaper configuration consumed by the session. It remains active until a theme or mode change reapplies that theme's wallpaper. Export the active theme to include the current wallpaper and preserve it in the exported theme. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` is a legacy migration input only.

When a theme is exported, the current wallpaper image is included when it is readable. Importing installs the theme; applying it activates its wallpaper. See [Importing and exporting themes](/docs/components/argvus-themes/import-and-export/).

The user-facing appearance controls use the Hyprland helper `hypr-wallpaper-pick.sh`, which commits the chosen path through `argvus config` instead of storing wallpaper state itself. Do not edit generated wallpaper configuration directly.
