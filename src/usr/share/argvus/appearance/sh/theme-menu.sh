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
  _dark_category="$(argvus_tr appearance theme.category.dark)"
  _light_category="$(argvus_tr appearance theme.category.light)"
  _category="$(run_menu "$(argvus_tr appearance theme.select)" \
    "$_dark_category >" \
    "$_light_category >" || true)"
  _category="$(printf '%s' "$_category" | sed 's/[[:space:]]*>[[:space:]]*$//')"
  [ -n "$_category" ] || exit 0

  _onedark="$(argvus_tr appearance theme.family.onedark)"
  _dracula="$(argvus_tr appearance theme.family.dracula)"
  _dark_aether="$(argvus_tr appearance theme.family.dark_aether)"
  _dark_silver="$(argvus_tr appearance theme.family.dark_silver)"
  _dark_slate="$(argvus_tr appearance theme.family.dark_slate)"
  _dark_universe="$(argvus_tr appearance theme.family.dark_universe)"
  _dark_gruvbox_high="$(argvus_tr appearance theme.family.dark_gruvbox_high)"
  _dark_gruvbox="$(argvus_tr appearance theme.family.dark_gruvbox)"
  _light_veil="$(argvus_tr appearance theme.family.light_veil)"
  _github_light="$(argvus_tr appearance theme.family.github_light)"
  _solarized_light="$(argvus_tr appearance theme.family.solarized_light)"
  _frost="$(argvus_tr appearance theme.family.frost)"
  _catppuccin_latte="$(argvus_tr appearance theme.family.catppuccin_latte)"
  _dark_rosepine="$(argvus_tr appearance theme.family.dark_rosepine)"
  _tokyo_night="$(argvus_tr appearance theme.family.tokyo_night)"
  _solitude="$(argvus_tr appearance theme.family.solitude)"
  _dark_sunset="$(argvus_tr appearance theme.family.dark_sunset)"
  _dark_hackerman="$(argvus_tr appearance theme.family.dark_hackerman)"
  case "$_category" in
    "$_dark_category")
      _family="$(run_menu "$_dark_category" \
        "$_onedark >" \
        "$_dracula >" \
        "$_dark_aether >" \
        "$_dark_silver >" \
        "$_dark_slate >" \
        "$_dark_universe >" \
        "$_dark_gruvbox_high >" \
        "$_dark_gruvbox >" \
        "$_dark_rosepine >" \
        "$_tokyo_night >" \
        "$_solitude >" \
        "$_dark_sunset >" \
        "$_dark_hackerman >" || true)" ;;
    "$_light_category")
      _family="$(run_menu "$_light_category" \
        "$_light_veil >" \
        "$_github_light >" \
        "$_solarized_light >" \
        "$_frost >" \
        "$_catppuccin_latte >" || true)" ;;
    *) continue ;;
  esac
  _family="$(printf '%s' "$_family" | sed 's/[[:space:]]*>[[:space:]]*$//')"
  _family="$(printf '%s' "$_family" | sed 's/[[:space:]]*$//')"
  [ -n "$_family" ] || exit 0

  case "$_family" in
    "$_onedark") _theme='argvus-onedark' ;;
    "$_dracula") _theme='argvus-dark-dracula' ;;
    "$_dark_aether") _theme='argvus-dark-aether' ;;
    "$_dark_silver") _theme='argvus-dark-silver' ;;
    "$_dark_slate") _theme='argvus-dark-slate' ;;
    "$_dark_universe") _theme='argvus-dark-universe' ;;
    "$_dark_gruvbox_high") _theme='argvus-dark-gruvbox-high' ;;
    "$_dark_gruvbox") _theme='argvus-dark-gruvbox' ;;
    "$_light_veil") _theme='argvus-light-veil' ;;
    "$_github_light") _theme='argvus-github-light' ;;
    "$_solarized_light") _theme='argvus-light-solarized' ;;
    "$_frost") _theme='argvus-light-frost' ;;
    "$_catppuccin_latte") _theme='argvus-light-catppuccin-latte' ;;
    "$_dark_rosepine") _theme='argvus-dark-rosepine' ;;
    "$_tokyo_night") _theme='argvus-dark-tokio-night' ;;
    "$_solitude") _theme='argvus-dark-solitude' ;;
    "$_dark_sunset") _theme='argvus-dark-sunset' ;;
    "$_dark_hackerman") _theme='argvus-dark-hackerman' ;;
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
