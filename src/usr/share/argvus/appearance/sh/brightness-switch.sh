#!/usr/bin/env sh
# Control display brightness via brightnessctl (laptop backlight) or
# ddcutil (desktop monitors with DDC/CI), with a rofi menu.
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
    brightnessctl) apply_brightnessctl "$_value" ;;
    ddcutil) apply_ddcutil "$_value" ;;
  esac
  _current="$(read_brightness)"
  notify_send "$(argvus_tr appearance brightness.title_short)" "${_current}%"
}

select_menu() {
  _current="$(read_brightness)"
  _prompt="$(argvus_tr appearance brightness.title "percent=$_current")"
  _inc="$(argvus_tr appearance brightness.increase)"
  _dec="$(argvus_tr appearance brightness.decrease)"

  _night_row=""
  if _night_status=$(argvus config display night-light status 2>/dev/null) &&
      printf '%s' "$_night_status" | jq -e '.available == true' >/dev/null 2>&1; then
    if printf '%s' "$_night_status" | jq -e '.active == true' >/dev/null 2>&1; then
      _temperature=$(printf '%s' "$_night_status" | jq -r '.effective_temperature')
      _night_row="11 - $(argvus_tr appearance brightness.night_light_on "temperature=$_temperature")"
    else
      _night_row="11 - $(argvus_tr appearance brightness.night_light_off)"
    fi
  fi
  if [ "$BACKEND" = "none" ] && [ -z "$_night_row" ]; then
    notify_error "$(argvus_tr appearance brightness.title_short)" "$(argvus_tr appearance brightness.unavailable)"
    return 1
  fi
  _selection=$(
    {
      if [ "$BACKEND" != "none" ]; then
        printf '%s\n' "01 - $_inc +10%" "02 - $_inc +5%" "03 - $_dec -5%" "04 - $_dec -10%" \
          "05 - 10%" "06 - 25%" "07 - 50%" "08 - 75%" "09 - 90%" "10 - 100%"
      fi
      if [ -n "$_night_row" ]; then printf '%s\n' "$_night_row"; fi
    } | rofi -config "$(paths_config launcher/config/config.rasi)" -dmenu -p "$_prompt" -i -theme-str 'listview {lines: 11;}'
  )
  [ -z "$_selection" ] && return 1

  # Numeric action IDs stay stable across translations.
  case "${_selection%% *}" in
    01) apply "+10%" ;;
    02) apply "+5%" ;;
    03) apply "5%-" ;;
    04) apply "10%-" ;;
    05) apply "10%" ;;
    06) apply "25%" ;;
    07) apply "50%" ;;
    08) apply "75%" ;;
    09) apply "90%" ;;
    10) apply "100%" ;;
    11)
      [ -n "$_night_row" ] || return 1
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
