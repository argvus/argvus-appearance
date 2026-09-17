# Theme switching

`appearance/sh/theme-switch.sh` applies the selected theme. Concurrent switches
are serialized with `flock`. Runtime transitions use the Hyprland Lua DPMS API
and invoke `argvus-sessionctl reload` (the same command as SUPER + Shift + R)
after updating configuration. This centralizes the Hyprland, Waybar, Quickshell,
wallpaper, notification, idle and polkit lifecycle. Waybar must
restart even if blanking the display fails: a CSS reload does not update its
layer-shell margins. Signal cleanup restores the services and display.

Applying a Normal theme resets taskbar margins to `0,0,0,0`, borders to
disabled with rounding `0`, and window gaps to `3/1`. Applying a Float theme
resets taskbar margins to `20,20,20,1`, borders to enabled with rounding `4`,
and window gaps to `3/1`. The Control Panel can then change and apply these
values until the next theme switch, which acts as the mode reset.

Packaged files remain under `/usr/share/argvus/<component>/{config,sh,docs}`.
Managed user copies retain their compatibility paths under
`${ARGVUS_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}/argvus`.
Native overrides precede managed copies for reading and are not overwritten
by theme generation. Taskbar and telemetry share `waybar/themes` in user state;
missing files from either component must be merged without replacing custom files.

The Control Panel launches theme selection through a transient user service so
restarting the panel cannot terminate its own theme switch. The Control Center
reads its own theme resources and an accent-only cache, not the calendar cache.

For integration checks in an ecosystem checkout, run
`python tools/test-theme-switch.py` from `argvus-appearance` and
`python tools/test-paths.py` from `argvus-session`. The tests isolate configuration
and cache directories and replace runtime commands with recording doubles.
