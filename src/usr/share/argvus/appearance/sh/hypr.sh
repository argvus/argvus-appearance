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

# Official theme wallpapers are deliberately restricted to abstract assets.
# Landscape files remain available to the manual wallpaper picker.
argvus_theme_wallpaper() {
  _theme="${1%-float}"
  case "$_theme" in
    argvus-dark) _wallpaper_name="argvus-dark.jxl" ;;
    argvus-light) _wallpaper_name="argvus-light.jxl" ;;
    dracula) _wallpaper_name="abstract/dark/dracula-abstract-dark.jxl" ;;
    gruvbox-dark) _wallpaper_name="abstract/dark/gruvbox-abstract-dark.jxl" ;;
    gruvbox-high-dark) _wallpaper_name="abstract/dark/gruvbox-high-abstract-dark.jxl" ;;
    monokai-dark) _wallpaper_name="abstract/dark/monokai-abstract-dark.jxl" ;;
    one-dark) _wallpaper_name="abstract/dark/one-dark-abstract-dark.jxl" ;;
    rose-pine) _wallpaper_name="abstract/dark/rose-pine-abstract-dark.jxl" ;;
    silver-dark) _wallpaper_name="abstract/dark/silver-abstract-dark.jxl" ;;
    slate-dark) _wallpaper_name="abstract/dark/slate-abstract-dark.jxl" ;;
    sunset) _wallpaper_name="abstract/dark/sunset-abstract-dark.jxl" ;;
    tokyo-night) _wallpaper_name="abstract/dark/tokyo-night-abstract-dark.jxl" ;;
    hackerman) _wallpaper_name="abstract/dark/hackerman-abstract-dark.jxl" ;;
    solitude) _wallpaper_name="abstract/dark/solitude-abstract-dark.jxl" ;;
    universe) _wallpaper_name="abstract/dark/universe-abstract-dark.jxl" ;;
    catppuccin-latte) _wallpaper_name="abstract/light/catppuccin-latte-abstract-light.jxl" ;;
    frost) _wallpaper_name="abstract/light/frost-abstract-light.jxl" ;;
    github-light) _wallpaper_name="abstract/light/github-light-abstract-light.jxl" ;;
    gruvbox-light) _wallpaper_name="abstract/light/gruvbox-abstract-light.jxl" ;;
    solarized-light) _wallpaper_name="abstract/light/solarized-abstract-light.jxl" ;;
    one-light) _wallpaper_name="abstract/light/one-light-abstract-light.jxl" ;;
    everforest-light) _wallpaper_name="abstract/light/everforest-abstract-light.jxl" ;;
    *) return 1 ;;
  esac
  _wallpaper_root="${WALLPAPER_ROOT:-${ARGVUS_BACKGROUNDS_DIR:-/usr/share/backgrounds}/argvus}"
  _wallpaper_path="${_wallpaper_root}/${_wallpaper_name}"
  [ -f "$_wallpaper_path" ] || return 1
  printf '%s\n' "$_wallpaper_path"
}

# A custom wallpaper is independent from the active visual theme. Keep its
# selected path in the user-owned ARGVUS state so the session service can
# restore it without relying on a transient systemd manager environment.
CUSTOM_WALLPAPER_STATE="$ARGVUS_CONFIG_HOME/argvus/.wallpaper-custom"

persist_custom_wallpaper() {
  _wallpaper_path="$1"
  mkdir -p "${CUSTOM_WALLPAPER_STATE%/*}"
  printf '%s\n' "$_wallpaper_path" > "$CUSTOM_WALLPAPER_STATE"
}

read_custom_wallpaper() {
  [ -f "$CUSTOM_WALLPAPER_STATE" ] || return 1
  sed -n '1p' "$CUSTOM_WALLPAPER_STATE"
}

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
    # argvus-wallpaper.service reads WALLPAPER_PATH from the user manager
    # environment. Refresh it before restarting the service, otherwise every
    # theme change starts the wallpaper service with its old/default image.
    systemctl --user set-environment WALLPAPER_PATH="$_wallpaper_path" \
      >/dev/null 2>&1 || true
    systemctl --user restart argvus-wallpaper.service >/dev/null 2>&1 && return 0
  fi

  systemctl --user stop argvus-wallpaper.service hyprpaper.service 2>/dev/null || true
  pkill -x swaybg 2>/dev/null || true
  pkill -x hyprpaper 2>/dev/null || true

  # The packaged wallpapers are JPEG XL. Prefer the backend that can load the
  # format before trying the low-power fallback, which may support fewer image
  # codecs depending on the installed build.
  case "$_wallpaper_path" in
    *.jxl) hypr_apply_hyprpaper_wallpaper "$_wallpaper_path" && return 0 ;;
  esac

  if hypr_low_power_session; then
    hypr_apply_swaybg_wallpaper "$_wallpaper_path" && return 0
  fi

  hypr_apply_hyprpaper_wallpaper "$_wallpaper_path" && return 0
  hypr_apply_swaybg_wallpaper "$_wallpaper_path" || return 0
}
