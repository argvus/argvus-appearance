#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

# SUPER+F5 alternates between the official ARGVUS Dark and ARGVUS Light themes.
# The switch itself is the same transaction used by SUPER+SHIFT+T
# (the theme-switch route), so wallpaper, GTK, Waybar and Rofi follow the new theme.
ACTIVE_FILE="$ARGVUS_CONFIG_HOME/argvus/data/.active-theme"
[ -s "$ACTIVE_FILE" ] || ACTIVE_FILE="$ARGVUS_CONFIG_HOME/argvus/.active-theme"
THEME="$(sed -n '1p' "$ACTIVE_FILE" 2>/dev/null || true)"
[ -n "$THEME" ] || THEME="argvus-dark"
THEME="${THEME%-float}"

case "$THEME" in
  argvus-light) TARGET="argvus-dark" ;;
  *) TARGET="argvus-light" ;;
esac

ARGVUS_ACCENT_OFFICIAL=1 exec argvus theme-switch "$TARGET"
