#!/usr/bin/env sh
# layout-mode-menu - Rofi picker for the Sticky/Float layout mode, independent
# of theme selection. Same two-pass structure as theme-menu.sh.
# shellcheck disable=SC1090,SC1091

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

LAYOUT_MODE_SWITCH="$(paths_config appearance/sh/layout-mode-switch.sh)"
ROFI_CONFIG="$(paths_config launcher/config/config.rasi)"

run_menu() {
  _prompt="$1"
  shift
  printf '%s\n' "$@" | rofi -config "$ROFI_CONFIG" -dmenu -i -p "$_prompt" \
    -kb-move-char-back 'Control+b' \
    -kb-move-char-forward 'Control+f' \
    -kb-accept-entry 'Return,KP_Enter,Right' \
    -kb-cancel 'Escape,Left'
}

_sticky="$(argvus_tr appearance theme.model.sticky)"
_float="$(argvus_tr appearance theme.model.float)"

_mode="$(run_menu "$(argvus_tr appearance layout_mode.select)" "$_sticky" "$_float")" || exit 0
_mode="$(printf '%s' "$_mode" | sed 's/[[:space:]]*$//')"

case "$_mode" in
  "$_sticky") exec sh "$LAYOUT_MODE_SWITCH" sticky >/dev/null 2>&1 ;;
  "$_float") exec sh "$LAYOUT_MODE_SWITCH" float >/dev/null 2>&1 ;;
  *) exit 0 ;;
esac
