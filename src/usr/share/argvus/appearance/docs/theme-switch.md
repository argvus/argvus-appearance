# Theme switching

`argvus theme-switch <theme>` (or `argvus theme apply <theme>`) applies the
selected theme. The route runs `argvus config theme-apply`, which holds the
switch transaction in Rust and serializes concurrent switches with `flock`,
waiting at most 60 seconds for the lock. The switch renders the theme build,
points `generated/theme/current` at it and reloads the running consumers in
place, as the theme registry (`/usr/share/argvus/theme/consumers.d`) declares:
the Taskbar bars re-read their stylesheet, the Control Panel re-reads its
`Theme.qml`, Hyprland evaluates the new colours, hyprpaper shows the theme's
wallpaper, and Dunst, btop and kitty reload their configuration. The projection
manifest drives the session controller's targeted runtime actions. Applying a
custom user theme forces restarts of `argvus-taskbar.service`,
`argvus-hyprland.service`, `argvus-wallpaper.service` and
`argvus-control-panel.service`, so its complete exported profile reaches each
surface even when the values match the previous projection. The whole session
target is not restarted.

Sticky/Spaced is the layout mode (`/layout/variant` in `argvus config`,
`sticky` or `spaced`) and is independent of the active theme: selecting a
theme never changes it, and switching the mode never changes the theme. The
mode selector (`argvus layout-mode-menu`, `SUPER + Shift + M`) applies the
complete preset through the Rust coordinator. It prepares the final taskbar
edge before rendering and skips theme reapplication for position-only or
Tile/Floating changes. Tab switches groups and arrows navigate within the
focused group. Progress stays inside the selector; its runtime commands do
not start a session splash. Failed or pending applications stay visible.

Control Center's `Appearance > Mode` screen retains the compatibility route
`appearance/sh/layout-mode-switch.sh <sticky|spaced>`. That route reasserts the
mode defaults and reapplies the active theme family. The preset coordinator
uses the same configuration and theme transaction directly. Required surface
restarts are grouped in one systemd transaction. The mode geometry takes
precedence over geometry stored in a theme profile. Other session flows retain
their loading overlay when recreating surfaces. Applying any theme replaces independent visual edits with that
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

Open `argvus theme-selector`, `argvus theme-switch` without arguments, or `SUPER + Shift + T`. The independent GTK overlay opens on the active monitor, with a central preview and neighboring cards. Search or filter All/Dark/Light; use arrows, the mouse wheel or side cards to browse. Enter or Apply theme confirms; Escape or Close cancels. Browsing never changes the desktop. Installed system and user themes share the existing catalog. A valid manifest `preview` is preferred; otherwise wallpaper and palette produce an illustrative desktop, not an exact rendering of application overrides. Missing images use palette colors. Application uses the existing theme transaction and preserves Sticky/Spaced. Failures remain visible for retry. JXL thumbnails require `djxl` from `libjxl`; derived thumbnails live under the XDG cache in `argvus/theme-selector/v2`.

After applying a highlight color, `argvus config accent` also publishes the
validated `#RRGGBB` value to the per-UID greeter projection at
`/var/lib/argvus/greeter/themes/<uid>.accent`. This public file lets the
pre-authentication greeter and both session handoff spinners use the same
accent without granting them access to the user's private configuration.

For integration checks in an ecosystem checkout, run
`python tools/test-theme-switch.py` from `argvus-appearance` and
`python tools/test-paths.py` from `argvus-session`. The tests isolate configuration
and cache directories and replace runtime commands with recording doubles.

The visual `argvus layout-mode-menu` picker now offers eight complete presets:
Sticky/Spaced, Tile/Floating windows, and Top/Bottom primary taskbar. The config
coordinator applies geometry first, final bar position second, and window policy
last. Failed theme transactions propagate their status; pending session changes
remain visible rather than closing the picker as a completed application.

Integration tests mock `dbus-update-activation-environment` and `wpctl` as well
as systemctl.
Their runtime directory is temporary and their D-Bus address points to an absent
socket, so environment imports cannot overwrite the live session manager state.
