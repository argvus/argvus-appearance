# Theme switching

`appearance/sh/theme-switch.sh` applies the selected theme. Concurrent switches
are serialized with `flock`. Runtime transitions use the Hyprland Lua DPMS API
and invoke `argvus-sessionctl reload` (the same command as SUPER + Shift + R)
after updating configuration. This centralizes the Hyprland, Waybar, Quickshell,
wallpaper, notification, idle and polkit lifecycle. Waybar must
restart even if blanking the display fails: a CSS reload does not update its
layer-shell margins. Signal cleanup restores the services and display.

Sticky/Float is the layout mode (`/layout/variant` in `argvus-config`,
`sticky` or `float`) and is independent of the active theme: selecting a
theme never changes it, and switching the mode never changes the theme. The
mode is applied with `appearance/sh/layout-mode-switch.sh <sticky|float>`,
triggered either from the `SUPER + Shift + M` Rofi picker
(`appearance/sh/layout-mode-menu.sh`) or from Control Center's
`Appearance > Mode` screen. Applying Sticky resets taskbar margins, border
rounding and window gaps to the sticky defaults; applying Float resets them to
the float defaults (see `reset_layout_geometry` in `argvus-config`). The
Control Panel can then change and apply its own values until the next mode
switch or theme switch, both of which reset to the active mode's defaults.

Packaged files remain under `/usr/share/argvus/<component>/{config,sh,docs}`.
Managed user copies retain their compatibility paths under
`${ARGVUS_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}/argvus`.
Native overrides precede managed copies for reading and are not overwritten
by theme generation. Taskbar and telemetry share `waybar/themes` in user state;
missing files from either component must be merged without replacing custom files.

The Control Panel launches theme selection through a transient user service so
restarting the panel cannot terminate its own theme switch. The Control Center
reads its own theme resources and an accent-only cache, not the calendar cache.

The `SUPER + Shift + T` Rofi selector is hierarchical: choose the localized
Dark or Light category, then the ARGVUS family, which applies immediately
under whichever mode is already active. The Control Center uses the same
category and family hierarchy; imported custom profiles remain in a separate
section. In Rofi, Right advances to the selected level, Left returns one
level, and Escape closes the selector from any level.

After applying a highlight color, `accent-switch.sh` also publishes the
validated `#RRGGBB` value to the per-UID greeter projection at
`/var/lib/argvus/greeter/themes/<uid>.accent`. This public file lets the
pre-authentication greeter and both session handoff spinners use the same
accent without granting them access to the user's private configuration.

For integration checks in an ecosystem checkout, run
`python tools/test-theme-switch.py` from `argvus-appearance` and
`python tools/test-paths.py` from `argvus-session`. The tests isolate configuration
and cache directories and replace runtime commands with recording doubles.
