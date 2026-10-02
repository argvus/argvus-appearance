---
title: Wallpapers
description: Use built-in and custom ARGVUS wallpapers.
---

Built-in JPEG XL wallpapers are installed by `argvus-wallpapers` under `/usr/share/backgrounds/argvus/`. In **Control Center → Appearance → Wallpapers**, they are organized as `Abstract` or `Landscape`, then by `Dark` or `Light`. The root `argvus-dark.jxl` and `argvus-light.jxl` files appear under the abstract fallback groups. Theme switching uses only the abstract files in `abstract/dark` and `abstract/light`; landscape files are optional manual choices. Press `SUPER + Y` to open this Control Center screen directly. The first entry also accepts a custom image from HOME; the selected file becomes the user's custom wallpaper state.

The first entry opens a file chooser for a custom image. A selected custom wallpaper is independent user state: it is stored as `/appearance/wallpaper` together with `/appearance/wallpaper_custom` in `config.json`, and `argvus-config` projects it into the Hyprland wallpaper configuration consumed by the session. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` is a legacy migration input only. Selecting another bundled wallpaper replaces that custom selection; it does not edit the theme's logical definition.

When a theme profile is exported, the current custom wallpaper is included only when it is a readable file. Importing a profile restores the packaged wallpaper to a managed profile location when possible; if its original path is unavailable, the imported profile does not silently point at a missing file. See [Themes and accents](./themes/) for the separation between importing and applying a profile.

The user-facing appearance controls use the Hyprland helper `hypr-wallpaper-pick.sh`, which commits the chosen path through `argvus-config` instead of storing wallpaper state itself. Applying a custom theme profile can restore its embedded wallpaper, but importing a profile alone does not activate it. Do not edit generated wallpaper configuration directly.
