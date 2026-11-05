# Theme switching

`argvus theme-switch <theme>` (or `argvus theme apply <theme>`) applies the
selected theme. The route runs `argvus config theme-apply`, which holds the
switch transaction in Rust and serializes concurrent switches with `flock`,
waiting at most 60 seconds for the lock. The switch renders the theme build,
points `generated/theme/current` at it and reloads the running consumers in
place, as the theme registry (`/usr/share/argvus/theme/consumers.d`) declares:
the Waybar bars re-read their stylesheet, the Control Panel re-reads its
`Theme.qml`, Hyprland evaluates the new colours, hyprpaper shows the theme's
wallpaper, and Dunst, btop and kitty reload their configuration. The projection
manifest drives the session controller's targeted runtime actions. Applying a
custom user theme forces restarts of `argvus-taskbar.service`,
`argvus-hyprland.service`, `argvus-wallpaper.service` and
`argvus-control-panel.service`, so its complete exported profile reaches each
surface even when the values match the previous projection. The whole session
target is not restarted.

Sticky/Float is the layout mode (`/layout/variant` in `argvus config`,
`sticky` or `float`) and is independent of the active theme: selecting a
theme never changes it, and switching the mode never changes the theme. The
mode is applied with `appearance/sh/layout-mode-switch.sh <sticky|float>`,
triggered either from the `SUPER + Shift + M` Rofi picker
(`appearance/sh/layout-mode-menu.sh`) or from Control Center's
`Appearance > Mode` screen. Applying Sticky resets taskbar margins, border
rounding and window gaps to the sticky defaults; applying Float resets them to
the float defaults (see `reset_layout_geometry` in `argvus config`). The
script writes the mode and runs the theme transaction for the active family.
Every mode switch reapplies the selected mode's spacing, border and taskbar
geometry, then restarts `argvus-taskbar.service`,
`argvus-widget-telemetry.service` and `argvus-hyprland.service`, including when
the mode was already selected. The mode's geometry takes precedence over
geometry stored in a theme profile. The session controller may show its loading
overlay when a surface must be recreated, but it does not restart the whole
session target. Applying any theme replaces independent visual edits with that
theme's exported profile or the packaged defaults when it has no profile. To
keep personal visual settings across theme or mode changes, save them through
Control Center's **Export theme** action. An exported profile includes its
appearance settings and per-surface effects in `effects.conf` when present.

Packaged files remain under `/usr/share/argvus/<component>/{config,sh,docs}`.
Managed user copies retain their compatibility paths under
`${ARGVUS_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}/argvus`.
Native overrides precede managed copies for reading and are not overwritten
by theme generation. Themed files are not copied per theme any more: they come
from the theme build, rendered from the theme's manifest
(`/usr/share/argvus/themes/<id>/theme.toml`, or a user theme under
`$XDG_DATA_HOME/argvus/themes`). The first switch after the update moves the
per-theme copies of older switches (`data/<app>/themes/`) to
`data/backups/theme-copies-<seconds>/`.

The Control Panel launches theme selection through a transient user service, so
the switch does not depend on the panel process that asked for it. The Control Center
reads the TUI palette of the build, not the calendar cache.

The `SUPER + Shift + T` Rofi selector is hierarchical: choose the localized
Dark or Light category, then the theme (ARGVUS first, then the installed themes, the user's included,
as `argvus theme list` reports them), which applies immediately
under whichever mode is already active. The Control Center uses the same
category and family hierarchy; imported custom profiles remain in a separate
section. In Rofi, Right advances to the selected level, Left returns one
level, and Escape closes the selector from any level.

After applying a highlight color, `argvus config accent` also publishes the
validated `#RRGGBB` value to the per-UID greeter projection at
`/var/lib/argvus/greeter/themes/<uid>.accent`. This public file lets the
pre-authentication greeter and both session handoff spinners use the same
accent without granting them access to the user's private configuration.

For integration checks in an ecosystem checkout, run
`python tools/test-theme-switch.py` from `argvus-appearance` and
`python tools/test-paths.py` from `argvus-session`. The tests isolate configuration
and cache directories and replace runtime commands with recording doubles.
