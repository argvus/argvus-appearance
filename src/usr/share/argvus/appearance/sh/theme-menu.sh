#!/usr/bin/env sh
# Hierarchical Rofi theme selector, using the same two-pass transaction as
# argvus-removable-devices's removable-device menu.

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

THEME_SWITCH="$(paths_config appearance/sh/theme-switch.sh)"
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

while :; do
  _onedark="$(argvus_tr appearance theme.family.onedark)"
  _dracula="$(argvus_tr appearance theme.family.dracula)"
  _dark_aether="$(argvus_tr appearance theme.family.dark_aether)"
  _dark_silver="$(argvus_tr appearance theme.family.dark_silver)"
  _dark_slate="$(argvus_tr appearance theme.family.dark_slate)"
  _dark_universe="$(argvus_tr appearance theme.family.dark_universe)"
  _gruvbox_dark_medium="$(argvus_tr appearance theme.family.gruvbox_dark_medium)"
  _light_veil="$(argvus_tr appearance theme.family.light_veil)"
  _frost="$(argvus_tr appearance theme.family.frost)"
  _catppuccin_latte="$(argvus_tr appearance theme.family.catppuccin_latte)"
  _rosepine="$(argvus_tr appearance theme.family.rosepine)"
  _tokyo_night="$(argvus_tr appearance theme.family.tokyo_night)"
  _family="$(run_menu "$(argvus_tr appearance theme.select)" \
    "$_onedark" \
    "$_dracula" \
    "$_dark_aether" \
    "$_dark_silver" \
    "$_dark_slate" \
    "$_dark_universe" \
    "$_gruvbox_dark_medium" \
    "$_light_veil" \
    "$_frost" \
    "$_catppuccin_latte" \
    "$_rosepine" \
    "$_tokyo_night" || true)"
  _family="$(printf '%s' "$_family" | sed 's/[[:space:]]*$//')"
  [ -n "$_family" ] || exit 0

  case "$_family" in
    "$_onedark") _theme='argvus-onedark' ;;
    "$_dracula") _theme='argvus-dracula' ;;
    "$_dark_aether") _theme='argvus-dark-aether' ;;
    "$_dark_silver") _theme='argvus-dark-silver' ;;
    "$_dark_slate") _theme='argvus-dark-slate' ;;
    "$_dark_universe") _theme='argvus-dark-universe' ;;
    "$_gruvbox_dark_medium") _theme='argvus-gruvbox-dark-medium' ;;
    "$_light_veil") _theme='argvus-light-veil' ;;
    "$_frost") _theme='argvus-frost' ;;
    "$_catppuccin_latte") _theme='argvus-catppuccin-latte' ;;
    "$_rosepine") _theme='argvus-rosepine' ;;
    "$_tokyo_night") _theme='argvus-tokyo-night' ;;
    *) continue ;;
  esac

  _model="$(run_menu "$_family" \
    "$(argvus_tr appearance theme.model.sticky)" \
    "$(argvus_tr appearance theme.model.float)" || true)"
  _model="$(printf '%s' "$_model" | sed 's/[[:space:]]*$//')"
  case "$_model" in
    "$(argvus_tr appearance theme.model.sticky)") exec sh "$THEME_SWITCH" "$_theme" >/dev/null 2>&1 ;;
    "$(argvus_tr appearance theme.model.float)") exec sh "$THEME_SWITCH" "${_theme}-float" >/dev/null 2>&1 ;;
    *) continue ;;
  esac
done
