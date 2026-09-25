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
  if ! _category="$(run_menu "$(argvus_tr appearance theme.select)" \
    "$_dark_category >" \
    "$_light_category >")"; then
    # Left/Escape at the root closes the selector.
    exit 0
  fi
  _category="$(printf '%s' "$_category" | sed 's/[[:space:]]*>[[:space:]]*$//')"
  [ -n "$_category" ] || exit 0

  _onedark="$(argvus_tr appearance theme.family.one_dark)"
  _dracula="$(argvus_tr appearance theme.family.dracula)"
  _dark_aether="$(argvus_tr appearance theme.family.argvus_dark)"
  _dark_silver="$(argvus_tr appearance theme.family.silver_dark)"
  _dark_slate="$(argvus_tr appearance theme.family.slate_dark)"
  _dark_universe="$(argvus_tr appearance theme.family.universe)"
  _dark_gruvbox_high="$(argvus_tr appearance theme.family.gruvbox_high_dark)"
  _dark_gruvbox="$(argvus_tr appearance theme.family.gruvbox_dark)"
  _light_veil="$(argvus_tr appearance theme.family.argvus_light)"
  _github_light="$(argvus_tr appearance theme.family.github_light)"
  _solarized_light="$(argvus_tr appearance theme.family.solarized_light)"
  _frost="$(argvus_tr appearance theme.family.frost)"
  _catppuccin_latte="$(argvus_tr appearance theme.family.catppuccin_latte)"
  _light_gruvbox="$(argvus_tr appearance theme.family.gruvbox_light)"
  _dark_rose_pine="$(argvus_tr appearance theme.family.rose_pine)"
  _tokyo_night="$(argvus_tr appearance theme.family.tokyo_night)"
  _solitude="$(argvus_tr appearance theme.family.solitude)"
  _dark_sunset="$(argvus_tr appearance theme.family.sunset)"
  _dark_hackerman="$(argvus_tr appearance theme.family.hackerman)"
  _dark_monokai="$(argvus_tr appearance theme.family.monokai_dark)"
  # Keep the family and model menus nested so Left returns exactly one level:
  # model -> family, family -> category, category -> close.
  while :; do
    case "$_category" in
      "$_dark_category")
        if ! _family="$(run_menu "$_dark_category" \
          "$_dark_aether >" \
          "$_onedark >" \
          "$_dracula >" \
          "$_dark_silver >" \
          "$_dark_slate >" \
          "$_dark_universe >" \
          "$_dark_gruvbox_high >" \
          "$_dark_gruvbox >" \
          "$_dark_rose_pine >" \
          "$_tokyo_night >" \
          "$_solitude >" \
          "$_dark_sunset >" \
          "$_dark_hackerman >" \
          "$_dark_monokai >")"; then
          break
        fi
        ;;
      "$_light_category")
        _family="$(run_menu "$_light_category" \
          "$_light_veil >" \
          "$_github_light >" \
          "$_solarized_light >" \
          "$_frost >" \
          "$_catppuccin_latte >" \
          "$_light_gruvbox >")" || break
        ;;
      *) break ;;
    esac
    _family="$(printf '%s' "$_family" | sed 's/[[:space:]]*>[[:space:]]*$//')"
    _family="$(printf '%s' "$_family" | sed 's/[[:space:]]*$//')"
    [ -n "$_family" ] || break

    case "$_family" in
      "$_onedark") _theme='one-dark' ;;
      "$_dracula") _theme='dracula' ;;
      "$_dark_aether") _theme='argvus-dark' ;;
      "$_dark_silver") _theme='silver-dark' ;;
      "$_dark_slate") _theme='slate-dark' ;;
      "$_dark_universe") _theme='universe' ;;
      "$_dark_gruvbox_high") _theme='gruvbox-high-dark' ;;
      "$_dark_gruvbox") _theme='gruvbox-dark' ;;
      "$_light_veil") _theme='argvus-light' ;;
      "$_github_light") _theme='github-light' ;;
      "$_solarized_light") _theme='solarized-light' ;;
      "$_frost") _theme='frost' ;;
      "$_catppuccin_latte") _theme='catppuccin-latte' ;;
      "$_light_gruvbox") _theme='gruvbox-light' ;;
      "$_dark_rose_pine") _theme='rose-pine' ;;
      "$_tokyo_night") _theme='tokyo-night' ;;
      "$_solitude") _theme='solitude' ;;
      "$_dark_sunset") _theme='sunset' ;;
      "$_dark_hackerman") _theme='hackerman' ;;
      "$_dark_monokai") _theme='monokai-dark' ;;
      *) continue ;;
    esac

    _model="$(run_menu "$_family" \
      "$(argvus_tr appearance theme.model.sticky)" \
      "$(argvus_tr appearance theme.model.float)")" || continue
    _model="$(printf '%s' "$_model" | sed 's/[[:space:]]*$//')"
    case "$_model" in
      "$(argvus_tr appearance theme.model.sticky)") exec sh "$THEME_SWITCH" "$_theme" >/dev/null 2>&1 ;;
      "$(argvus_tr appearance theme.model.float)") exec sh "$THEME_SWITCH" "${_theme}-float" >/dev/null 2>&1 ;;
      *) continue ;;
    esac
  done
done
