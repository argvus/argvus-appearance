# shellcheck shell=sh disable=SC2034

# -- Hyprland-specific paths and helpers --------------------------------------

HYPRPAPER_FILE="$(paths_config appearance/config/hypr/hyprpaper.conf)"
HYPRLOCK_FILE="$(paths_config lock/config/hyprlock.conf)"

GET_HYPRPAPER_PATH=$(
  sed -n \
    -e "s|^[[:space:]]*path[[:space:]]*=[[:space:]]*~|$HOME|p" \
    -e "s|^[[:space:]]*path[[:space:]]*=[[:space:]]*\\(/.*\\)|\\1|p" \
  "$HYPRPAPER_FILE" |
  head -n1
)

GET_HYPRLOCK_PATH=$(
  sed -n \
    -e "s|^[[:space:]]*path[[:space:]]*=[[:space:]]*~|$HOME|p" \
    -e "s|^[[:space:]]*path[[:space:]]*=[[:space:]]*\\(/.*\\)|\\1|p" \
  "$HYPRLOCK_FILE" |
  head -n1
)

WALLPAPER_PATH="$GET_HYPRPAPER_PATH"
HYPRLOCK_PATH="$GET_HYPRLOCK_PATH"

hypr_monitors() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl monitors 2>/dev/null |
      sed -n 's/^Monitor \([^ ]*\).*/\1/p'
  fi
}

hypr_wallpaper_runtime_config() {
  _wallpaper_path="$1"
  _runtime_config="$(paths_cache hypr)/hyprpaper.conf"

  mkdir -p "${_runtime_config%/*}"
  {
    _has_monitor=0
    for _monitor in $(hypr_monitors); do
      _has_monitor=1
      printf 'wallpaper {\n'
      printf '  monitor = %s\n' "$_monitor"
      printf '  path = %s\n' "$_wallpaper_path"
      printf '  fit_mode = cover\n'
      printf '}\n\n'
    done

    if [ "$_has_monitor" -eq 0 ]; then
      printf 'wallpaper {\n'
      printf '  monitor =\n'
      printf '  path = %s\n' "$_wallpaper_path"
      printf '  fit_mode = cover\n'
      printf '}\n\n'
    fi

    printf 'splash = false\n'
  } > "$_runtime_config"

  printf '%s\n' "$_runtime_config"
}

hypr_low_power_session() {
  [ "${ARGVUS_LOW_POWER:-0}" = "1" ] && return 0

  if command -v systemd-detect-virt >/dev/null 2>&1; then
    systemd-detect-virt --vm >/dev/null 2>&1
    return $?
  fi

  return 1
}

hypr_apply_swaybg_wallpaper() {
  _wallpaper_path="$1"
  _swaybg_log="$(paths_cache hypr)/swaybg.log"
  command -v swaybg >/dev/null 2>&1 || return 1

  mkdir -p "${_swaybg_log%/*}"
  nohup swaybg -m fill -i "$_wallpaper_path" >"$_swaybg_log" 2>&1 &
  sleep 0.2
  pgrep -x swaybg >/dev/null 2>&1
}

hypr_apply_hyprpaper_wallpaper() {
  _wallpaper_path="$1"
  _hyprpaper_log="$(paths_cache hypr)/hyprpaper.log"
  command -v hyprpaper >/dev/null 2>&1 || return 1

  mkdir -p "${_hyprpaper_log%/*}"
  _runtime_config="$(hypr_wallpaper_runtime_config "$_wallpaper_path")"
  hyprpaper -c "$_runtime_config" >"$_hyprpaper_log" 2>&1 &
  sleep 0.4
  pgrep -x hyprpaper >/dev/null 2>&1
}

hypr_apply_wallpaper() {
  _wallpaper_path="${1:-$WALLPAPER_PATH}"
  [ -n "$_wallpaper_path" ] || return 0
  [ -f "$_wallpaper_path" ] || return 0

  if command -v systemctl >/dev/null 2>&1 &&
     systemctl --user is-active --quiet argvus-session.target 2>/dev/null &&
     systemctl --user cat argvus-wallpaper.service >/dev/null 2>&1; then
    systemctl --user restart argvus-wallpaper.service >/dev/null 2>&1 && return 0
  fi

  systemctl --user stop argvus-wallpaper.service hyprpaper.service 2>/dev/null || true
  pkill -x swaybg 2>/dev/null || true
  pkill -x hyprpaper 2>/dev/null || true

  if hypr_low_power_session; then
    hypr_apply_swaybg_wallpaper "$_wallpaper_path" && return 0
  fi

  hypr_apply_hyprpaper_wallpaper "$_wallpaper_path" && return 0
  hypr_apply_swaybg_wallpaper "$_wallpaper_path" || return 0
}
