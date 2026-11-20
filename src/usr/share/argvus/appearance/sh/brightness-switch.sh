#!/usr/bin/env sh
# Control display brightness via brightnessctl (laptop backlight) or
# ddcutil (desktop monitors with DDC/CI), with a GTK menu.
# Usage: brightness-switch.sh [--status|--get|--up|--down|--set <percent>|--menu|PERCENT]
# shellcheck disable=SC1090,SC1091

set -u

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

BACKLIGHT_DEV="${ARGVUS_BACKLIGHT_DEV:-}"
BRIGHTNESS_DEV=""
BACKEND="none"

detect_backend() {
  BACKEND="none"

  if [ -n "$BACKLIGHT_DEV" ]; then
    BRIGHTNESS_DEV="$BACKLIGHT_DEV"
    BACKEND="brightnessctl"
    return 0
  fi

  if command -v brightnessctl >/dev/null 2>&1; then
    _class="$(brightnessctl -l 2>/dev/null | grep "class 'backlight'" | head -1 | sed -E "s/^Device '([^']+)'.*/\1/")"
    if [ -n "$_class" ]; then
      BRIGHTNESS_DEV="$_class"
      BACKEND="brightnessctl"
      return 0
    fi
  fi

  if command -v ddcutil >/dev/null 2>&1 && ddcutil getvcp 10 >/dev/null 2>&1; then
    BACKEND="ddcutil"
    return 0
  fi
}

read_brightnessctl() {
  brightnessctl -m --device "$BRIGHTNESS_DEV" 2>/dev/null \
    | cut -d, -f4 | tr -d '%' | head -1
}

read_ddcutil() {
  _vcp="$(ddcutil getvcp 10 2>/dev/null | grep -i "current value" | head -1)"
  [ -n "$_vcp" ] || { printf '0\n'; return 0; }
  _current="$(printf '%s\n' "$_vcp" | sed -E 's/.*current value[[:space:]]*=[[:space:]]*([0-9]+).*/\1/')"
  _max="$(printf '%s\n' "$_vcp" | sed -E 's/.*max value[[:space:]]*=[[:space:]]*([0-9]+).*/\1/')"
  [ "${_max:-0}" -gt 0 ] || { printf '0\n'; return 0; }
  printf '%s\n' "$((_current * 100 / _max))"
}

read_brightness() {
  case "$BACKEND" in
    brightnessctl) read_brightnessctl ;;
    ddcutil) read_ddcutil ;;
    *) printf '0\n' ;;
  esac
}

apply_brightnessctl() {
  brightnessctl set --device "$BRIGHTNESS_DEV" "$1"
}

apply_ddcutil() {
  _value="$1"
  _base="$(read_ddcutil)"
  case "$_value" in
    +*%) _adj="${_value%\%}"; _target=$((_base + ${_adj#+})) ;;
    *%-) _adj="${_value%-}"; _adj="${_adj%\%}"; _target=$((_base - _adj)) ;;
    *)   _target="${_value%\%}" ;;
  esac
  [ "$_target" -lt 0 ] && _target=0
  [ "$_target" -gt 100 ] && _target=100
  _vcp="$(ddcutil getvcp 10 2>/dev/null | grep -i "current value" | head -1)"
  _max="$(printf '%s\n' "$_vcp" | sed -E 's/.*max value[[:space:]]*=[[:space:]]*([0-9]+).*/\1/')"
  _max="${_max:-100}"
  _abs=$((_max * _target / 100))
  ddcutil setvcp 10 "$_abs"
}

apply() {
  _value="$1"
  case "$BACKEND" in
    none)
      notify_error "$(argvus_tr appearance brightness.title_short)" \
        "$(argvus_tr appearance brightness.unavailable)"
      return 1
      ;;
    brightnessctl) apply_brightnessctl "$_value" || return 1 ;;
    ddcutil) apply_ddcutil "$_value" || return 1 ;;
  esac
  _current="$(read_brightness)"
  notify_send "$(argvus_tr appearance brightness.title_short)" "${_current}%"
}

select_menu() {
  _backlight=false
  _current=""
  if [ "$BACKEND" != "none" ]; then
    _backlight=true
    _current="$(read_brightness)"
  fi
  if _night_status=$(argvus config display night-light status 2>/dev/null); then
    _night_status=$(printf '%s' "$_night_status" | jq -ce 'objects') || _night_status=null
  else
    _night_status=null
  fi
  _state=$(jq -nc --argjson backlight "$_backlight" --arg current "$_current" \
    --argjson night_light "$_night_status" \
    '{backlight: $backlight, percent: ($current | tonumber? // null), night_light: $night_light}') ||
    return 1
  _selection=$(printf '%s' "$_state" | argvus appearance-picker brightness) || return 1
  case "$_selection" in
    "") return 1 ;;
    "+10%"|"+5%"|"5%-"|"10%-"|"10%"|"25%"|"50%"|"75%"|"90%"|"100%")
      apply "$_selection"
      ;;
    night-light)
      if ! argvus config display night-light toggle; then
        notify_error "$(argvus_tr appearance brightness.title_short)" "$(argvus_tr appearance brightness.night_light_failed)"
        return 1
      fi
      ;;
    *) argvus_tr appearance brightness.invalid >&2; return 1 ;;
  esac
}

detect_backend

case "${1:-}" in
  --status) printf '%s\n' "$BACKEND" ;;
  --get)    read_brightness ;;
  --up)     apply "+5%" ;;
  --down)   apply "5%-" ;;
  --set)    [ -n "${2:-}" ] || { argvus_tr appearance brightness.missing_percent >&2; exit 1; }
            apply "$2" ;;
  --menu|"") select_menu ;;

  *)
    case "$1" in
      +*|*%-|*%) apply "$1" ;;
      *) apply "$1%" ;;
    esac
  ;;
esac
