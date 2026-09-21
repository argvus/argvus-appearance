#!/usr/bin/env sh
# shellcheck disable=SC1090,SC1091,SC2034

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"
ARGVUS_HYPR_HELPER="${ARGVUS_SYSTEM_CONFIG}/appearance/sh/hypr.sh"
[ -r "$ARGVUS_HYPR_HELPER" ] && . "$ARGVUS_HYPR_HELPER"
ARGVUS_MUTABLE_CONFIG=1
HYPRPAPER_FILE="$(paths_config appearance/config/hypr/hyprpaper.conf)"

# Start in the user's HOME so the chooser can select any supported image.
WALLPAPERS_DIR="${HOME:?}"
SELECTED_FILE=$(mktemp)

apply_wallpaper_runtime() {
  _wall="$1"
  hypr_apply_wallpaper "$_wall"
}

get_active_monitor() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl monitors 2>/dev/null |
      sed -n 's/^Monitor \([^ ]*\).*/\1/p' |
      head -n1
  fi
}

if [ "${1:-}" = "--apply" ]; then
  SELECTED_PATH="${2:-}"
  [ -f "$SELECTED_PATH" ] || {
    printf '%s\n' "wallpaper file not found" >&2
    exit 1
  }
  CONFIG_PATH=$(printf '%s\n' "$SELECTED_PATH" | sed "s|^$HOME|~|")
  MONITOR="$(get_active_monitor)"
  [ -n "$MONITOR" ] && sed -i "s|^[[:space:]]*monitor[[:space:]]*=.*$|  monitor = ${MONITOR}|" "$HYPRPAPER_FILE"
  sed -i "s|^[[:space:]]*path[[:space:]]*=.*$|  path =  ${CONFIG_PATH}|" "$HYPRPAPER_FILE"
  persist_custom_wallpaper "$SELECTED_PATH"
  apply_wallpaper_runtime "$SELECTED_PATH"
  sh "$(paths_config lock/sh/hyprlock-theme.sh)" --invalidate >/dev/null 2>&1 || true
  exit 0
fi

if command -v argvus >/dev/null 2>&1; then
  argvus-tui-terminal --class argvus-wallpaper-picker --term kitty -- \
    argvus --spf --chooser-file="$SELECTED_FILE" "$WALLPAPERS_DIR"
elif command -v spf >/dev/null 2>&1; then
  argvus-tui-terminal --class argvus-wallpaper-picker --term kitty -- \
    spf --chooser-file="$SELECTED_FILE" "$WALLPAPERS_DIR"
else
  argvus-tui-terminal --class argvus-wallpaper-picker --term kitty -- \
    yazi --chooser-file="$SELECTED_FILE" "$WALLPAPERS_DIR"
fi

SELECTED_PATH=$(cat "$SELECTED_FILE")
rm -f "$SELECTED_FILE"

[ -z "$SELECTED_PATH" ] && exit 0

# Convert $HOME to ~ for config file consistency
CONFIG_PATH=$(echo "$SELECTED_PATH" | sed "s|^$HOME|~|")
MONITOR="$(get_active_monitor)"

# Update hyprpaper.conf with ~ path
[ -n "$MONITOR" ] && sed -i "s|^[[:space:]]*monitor[[:space:]]*=.*$|  monitor = ${MONITOR}|" "$HYPRPAPER_FILE"
sed -i "s|^[[:space:]]*path[[:space:]]*=.*$|  path =  ${CONFIG_PATH}|" "$HYPRPAPER_FILE"
persist_custom_wallpaper "$SELECTED_PATH"

# Apply with full path
apply_wallpaper_runtime "$SELECTED_PATH"

# Rebuild Hyprlock config and invalidate the cached lock wallpaper.
sh "$(paths_config lock/sh/hyprlock-theme.sh)" --invalidate >/dev/null 2>&1 || true

notify-send "$(argvus_tr appearance wallpaper.notification.title)" \
  "$(argvus_tr appearance wallpaper.notification.message "name=$(basename "$SELECTED_PATH")")"
