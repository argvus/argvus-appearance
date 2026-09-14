#!/usr/bin/env sh
# Hierarchical Rofi theme selector, using the same two-pass transaction as
# argvus-taskbar-storage's removable-device menu.

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
  _family="$(run_menu 'Select theme' \
    'ARGVUS Dark Aether >' \
    'ARGVUS Dark Silver >' \
    'ARGVUS Dark Slate >' \
    'ARGVUS Dark Universe >' \
    'ARGVUS Light Veil >' || true)"
  _family="$(printf '%s' "$_family" | sed 's/[[:space:]]*$//')"
  [ -n "$_family" ] || exit 0

  case "$_family" in
    'ARGVUS Dark Aether >') _theme='argvus-dark-aether' ;;
    'ARGVUS Dark Silver >') _theme='argvus-dark-silver' ;;
    'ARGVUS Dark Slate >') _theme='argvus-dark-slate' ;;
    'ARGVUS Dark Universe >') _theme='argvus-dark-universe' ;;
    'ARGVUS Light Veil >') _theme='argvus-light-veil' ;;
    *) continue ;;
  esac

  _model="$(run_menu "$_family" Normal Float || true)"
  _model="$(printf '%s' "$_model" | sed 's/[[:space:]]*$//')"
  case "$_model" in
    Normal) exec sh "$THEME_SWITCH" "$_theme" >/dev/null 2>&1 ;;
    Float) exec sh "$THEME_SWITCH" "${_theme}-float" >/dev/null 2>&1 ;;
    *) continue ;;
  esac
done
