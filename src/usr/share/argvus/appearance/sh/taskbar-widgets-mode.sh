#!/usr/bin/env sh
# Project the canonical `taskbar.icons`/`taskbar.date`/`taskbar.time` config
# into the generated argvus-taskbar.jsonc (module visibility, date format,
# clock format). The config.json document is the single source of truth;
# this script only re-derives the generated Waybar config from it.
# Usage: taskbar-widgets-mode.sh {status|apply}
# shellcheck shell=sh disable=SC1090,SC1091,SC2034

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"
ARGVUS_MUTABLE_CONFIG=1

config_bool() {
  _pointer="$1"
  _default="$2"
  if command -v argvus-config >/dev/null 2>&1; then
    _value="$(argvus-config get "$_pointer" --effective --raw 2>/dev/null || true)"
    case "$_value" in
      true|false) printf '%s\n' "$_value"; return 0 ;;
    esac
  fi
  printf '%s\n' "$_default"
}

config_str() {
  _pointer="$1"
  _default="$2"
  if command -v argvus-config >/dev/null 2>&1; then
    _value="$(argvus-config get "$_pointer" --effective --raw 2>/dev/null || true)"
    [ -n "$_value" ] && { printf '%s\n' "$_value"; return 0; }
  fi
  printf '%s\n' "$_default"
}

# Replaces the "modules": [...] array found at/after the line matching $1 (a
# group block key, e.g. '"group/right-1":') with $2, leaving every other line
# (including JSONC comments/markers owned by other scripts) untouched. The
# source array may be single-line or span multiple lines (e.g.
# "modules": [\n  "x"\n]) — both forms are consumed as one unit.
replace_group_modules() {
  _block_key="$1"
  _new_array="$2"
  _file="$3"
  awk -v block="$_block_key" -v newline="    \"modules\": ${_new_array}" '
    BEGIN { in_block = 0; in_array = 0 }
    {
      if (!in_block && index($0, block) > 0) { in_block = 1 }
      if (in_block && !in_array && index($0, "\"modules\":") > 0) {
        in_array = 1
        if (index($0, "]") > 0) {
          print newline
          in_block = 0
          in_array = 0
        }
        next
      }
      if (in_array) {
        if (index($0, "]") > 0) {
          print newline
          in_array = 0
          in_block = 0
        }
        next
      }
      print
    }
  ' "$_file" > "${_file}.tmp" && mv "${_file}.tmp" "$_file"
}

# Extracts the raw JSON array text of "modules": [...] from the block
# matching $1, used to read the canonical (unfiltered) module order from the
# system-installed jsonc.
extract_group_modules() {
  _block_key="$1"
  _file="$2"
  awk -v block="$_block_key" '
    BEGIN { in_block = 0 }
    {
      if (index($0, block) > 0) { in_block = 1 }
      if (in_block && index($0, "\"modules\":") > 0) {
        print
        exit
      }
    }
  ' "$_file" | sed -n 's/.*"modules":[[:space:]]*\(\[[^]]*\]\).*/\1/p'
}

# Extracts the raw JSON array text of a top-level array field (e.g.
# '"modules-right":'), where the field itself marks the start of the array
# (unlike a nested "modules": label inside a block). Handles both single-line
# and multi-line arrays.
extract_field_array() {
  _field_match="$1"
  _file="$2"
  awk -v field="$_field_match" '
    BEGIN { in_array = 0 }
    {
      if (!in_array && index($0, field) > 0) {
        in_array = 1
        print
        if (index($0, "]") > 0) exit
        next
      }
      if (in_array) {
        print
        if (index($0, "]") > 0) exit
      }
    }
  ' "$_file" | tr '\n' ' ' | sed -n 's/.*\(\[[^]]*\]\).*/\1/p'
}

# Replaces a top-level array field (e.g. '"modules-left":') with $2, where
# the field itself marks the start of the array. The source array may be
# single-line or span multiple lines.
replace_field_array() {
  _field_match="$1"
  _new_array="$2"
  _file="$3"
  awk -v field="$_field_match" -v newline="  ${_field_match} ${_new_array}," '
    BEGIN { in_array = 0; done = 0 }
    {
      if (!done && !in_array && index($0, field) > 0) {
        in_array = 1
        if (index($0, "]") > 0) { print newline; in_array = 0; done = 1; next }
        next
      }
      if (in_array) {
        if (index($0, "]") > 0) { print newline; in_array = 0; done = 1; next }
        next
      }
      print
    }
  ' "$_file" > "${_file}.tmp" && mv "${_file}.tmp" "$_file"
}

# Replaces the first line matching $2 (a JSON field, e.g. '"format":') found
# at/after the line matching $1 (a block key) with $3.
replace_in_block() {
  _block_key="$1"
  _field_match="$2"
  _new_line="$3"
  _file="$4"
  awk -v block="$_block_key" -v field="$_field_match" -v newline="$_new_line" '
    BEGIN { in_block = 0 }
    {
      if (index($0, block) > 0) { in_block = 1 }
      if (in_block && index($0, field) > 0) {
        print newline
        in_block = 0
        next
      }
      print
    }
  ' "$_file" > "${_file}.tmp" && mv "${_file}.tmp" "$_file"
}

apply_mode() {
  _system_config="$(paths_system_config taskbar/config/argvus-taskbar.jsonc)"
  _target_config="$(paths_config taskbar/config/argvus-taskbar.jsonc)"
  [ -f "$_system_config" ] || {
    printf '%s\n' "missing system taskbar configuration: $_system_config" >&2
    return 1
  }
  [ -f "$_target_config" ] || {
    printf '%s\n' "missing taskbar configuration: $_target_config" >&2
    return 1
  }

  _audio_player_enabled="$(config_bool /taskbar/icons/audio_player_enabled true)"
  _launcher_enabled="$(config_bool /taskbar/icons/launcher_enabled true)"
  _network_enabled="$(config_bool /taskbar/icons/network_enabled true)"
  _power_profile_enabled="$(config_bool /taskbar/icons/power_profile_enabled true)"
  _keyboard_layout_enabled="$(config_bool /taskbar/icons/keyboard_layout_enabled true)"
  _memory_enabled="$(config_bool /taskbar/icons/memory_enabled true)"
  _cpu_enabled="$(config_bool /taskbar/icons/cpu_enabled true)"
  _cpu_temperature_enabled="$(config_bool /taskbar/icons/cpu_temperature_enabled true)"
  _gpu_temperature_enabled="$(config_bool /taskbar/icons/gpu_temperature_enabled true)"
  _date_format="$(config_str /taskbar/date/format weekday_day_month)"
  _time_seconds_enabled="$(config_bool /taskbar/time/seconds_enabled false)"
  _time_format="$(config_str /taskbar/time/format 24h)"

  if [ "$_audio_player_enabled" = true ]; then
    _left2_modules='["custom/spotify-mpris","mpris"]'
  else
    _left2_modules='[]'
  fi
  replace_group_modules '"group/left2":' "$_left2_modules" "$_target_config"

  if [ "$_launcher_enabled" = true ]; then
    _search_modules='["custom/search"]'
  else
    _search_modules='[]'
  fi
  replace_group_modules '"group/right-search":' "$_search_modules" "$_target_config"

  _right1_canonical="$(extract_group_modules '"group/right-1":' "$_system_config")"
  [ -n "$_right1_canonical" ] || _right1_canonical='[]'
  _right1_filtered="$(printf '%s' "$_right1_canonical" | jq -c \
    --argjson network "$_network_enabled" \
    --argjson power_profile "$_power_profile_enabled" \
    --argjson keyboard_layout "$_keyboard_layout_enabled" \
    --argjson memory "$_memory_enabled" \
    --argjson cpu "$_cpu_enabled" \
    --argjson cpu_temp "$_cpu_temperature_enabled" \
    --argjson gpu_temp "$_gpu_temperature_enabled" '
    map(select(
      (. == "custom/network" and $network) or
      (. == "power-profiles-daemon" and $power_profile) or
      (. == "hyprland/language" and $keyboard_layout) or
      (. == "memory" and $memory) or
      (. == "cpu" and $cpu) or
      (. == "custom/cpu-temp" and $cpu_temp) or
      (. == "custom/gpu-temp" and $gpu_temp) or
      (. == "battery")
    ))
  ')"
  replace_group_modules '"group/right-1":' "$_right1_filtered" "$_target_config"

  # A group whose "modules" array ended up empty still renders as a visible
  # empty box in Waybar unless its own key is also dropped from the
  # modules-left/modules-right array that references it. Always recompute
  # from the system (unfiltered) arrays, same rationale as the per-group
  # filtering above: re-adding a previously hidden group must work too.
  _left2_present=false
  [ "$_left2_modules" = '[]' ] || _left2_present=true
  _search_present=false
  [ "$_search_modules" = '[]' ] || _search_present=true
  _right1_present=false
  [ "$_right1_filtered" = '[]' ] || _right1_present=true

  _modules_left_canonical="$(extract_field_array '"modules-left":' "$_system_config")"
  _modules_left_filtered="$(printf '%s' "$_modules_left_canonical" | jq -c \
    --argjson left2 "$_left2_present" '
    map(select(. != "group/left2" or $left2))
  ')"
  replace_field_array '"modules-left":' "$_modules_left_filtered" "$_target_config"

  _modules_right_canonical="$(extract_field_array '"modules-right":' "$_system_config")"
  _modules_right_filtered="$(printf '%s' "$_modules_right_canonical" | jq -c \
    --argjson search "$_search_present" \
    --argjson icons "$_right1_present" '
    map(select(
      (. != "group/right-search" or $search) and
      (. != "group/right-1" or $icons)
    ))
  ')"
  replace_field_array '"modules-right":' "$_modules_right_filtered" "$_target_config"

  replace_in_block '"custom/date":' '"exec":' \
    "    \"exec\": \"/usr/share/argvus/taskbar/sh/waybar-date.sh ${_date_format}\"," \
    "$_target_config"

  case "${_time_format}:${_time_seconds_enabled}" in
    24h:false) _clock_strftime='%H:%M' ;   _clock_interval=60 ;;
    24h:true)  _clock_strftime='%H:%M:%S' ; _clock_interval=1 ;;
    12h:false) _clock_strftime='%I:%M %p' ; _clock_interval=60 ;;
    12h:true)  _clock_strftime='%I:%M:%S %p' ; _clock_interval=1 ;;
    *)         _clock_strftime='%H:%M' ;   _clock_interval=60 ;;
  esac
  replace_in_block '"clock#time":' '"format":' \
    "    \"format\": \"<span font_family='Symbols Nerd Font Mono'>󰅐</span> {:L${_clock_strftime}}\"," \
    "$_target_config"
  # Waybar's "clock" module defaults to a 60s refresh interval, so seconds
  # shown in the format string would appear to freeze for up to a minute at
  # a time unless the interval is tightened to 1s whenever seconds are on.
  replace_in_block '"clock#time":' '"interval":' \
    "    \"interval\": ${_clock_interval}" \
    "$_target_config"
}

status() {
  if ! command -v argvus-config >/dev/null 2>&1; then
    printf '%s\n' "argvus-config unavailable" >&2
    return 1
  fi
  argvus-config get /taskbar --effective
}

case "${1:-status}" in
  status)
    status
    ;;
  apply)
    apply_mode
    ;;
  *)
    printf '%s\n' "usage: $0 {status|apply}" >&2
    exit 2
    ;;
esac
