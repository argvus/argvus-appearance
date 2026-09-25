#!/usr/bin/env sh
# Apply one highlight color without changing theme backgrounds.
# Usage: accent-switch.sh [COLOR|--apply|--startup|--theme-default]
# shellcheck disable=SC1090,SC1091,SC2034

set -u

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"
ARGVUS_MUTABLE_CONFIG=1

STATE_DIR="${ARGVUS_CONFIG_HOME}/argvus"
ACCENT_FILE="${STATE_DIR}/.accent-color"
ACTIVE_FILE="${STATE_DIR}/.active-theme"
GREETER_THEME_STATE_DIR="${ARGVUS_GREETER_THEME_STATE_DIR:-/var/lib/argvus/greeter/themes}"
DEFAULT_ACCENT="#798186"
DEFAULT_THEME="argvus-dark"
RUNTIME=1
NOTIFY=1

read_state() {
  _state_file="$1"
  _fallback="$2"
  if [ -s "$_state_file" ]; then
    sed -n '1{s/\r$//;s/^[[:space:]]*//;s/[[:space:]]*$//;p;}' "$_state_file"
  else
    printf '%s\n' "$_fallback"
  fi
}

canonical_theme_id() {
  case "$1" in
    argvus-catppuccin-latte|argvus-light-catppuccin-latte) printf '%s\n' "catppuccin-latte" ;;
    argvus-catppuccin-latte-float|argvus-light-catppuccin-latte-float) printf '%s\n' "catppuccin-latte-float" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

theme_default_accent() {
  case "$1" in
    one-dark|one-dark-float) printf '#61AFEF\n' ;;
    dracula|dracula-float) printf '#BD93F9\n' ;;
    argvus-dark|argvus-dark-float) printf '#3590bd\n' ;;
    silver-dark|silver-dark-float) printf '#595959\n' ;;
    argvus-light|argvus-light-float) printf '#181818\n' ;;
    github-light|github-light-float) printf '#0969DA\n' ;;
    one-light|one-light-float) printf '#4078F2\n' ;;
    everforest-light|everforest-light-float) printf '#3A94C5\n' ;;
    solarized-light|solarized-light-float) printf '#268BD2\n' ;;
    rose-pine|rose-pine-float) printf '#C4A7E7\n' ;;
    frost|frost-float) printf '#0969DA\n' ;;
    catppuccin-latte|catppuccin-latte-float) printf '#1E66F5\n' ;;
    gruvbox-light|gruvbox-light-float) printf '#458588\n' ;;
    slate-dark|slate-dark-float) printf '#7391a5\n' ;;
    universe|universe-float) printf '#eeeeee\n' ;;
    gruvbox-high-dark|gruvbox-high-dark-float) printf '#D79921\n' ;;
    gruvbox-dark|gruvbox-dark-float) printf '#D4BE98\n' ;;
    tokyo-night|tokyo-night-float) printf '#7AA2F7\n' ;;
    solitude|solitude-float) printf '#798186\n' ;;
    sunset|sunset-float) printf '#E2BE8A\n' ;;
    hackerman|hackerman-float) printf '#82FB9C\n' ;;
    monokai-dark|monokai-dark-float) printf '#78DCE8\n' ;;
    *) return 1 ;;
  esac
}

read_accent_state() {
  _state_theme="$(read_state "$ACTIVE_FILE" "$DEFAULT_THEME")"
  _state_default="$(theme_default_accent "$_state_theme" 2>/dev/null || printf '%s\n' "$DEFAULT_ACCENT")"
  _state_accent="$(read_state "$ACCENT_FILE" "$_state_default")"
  case "$_state_accent" in
    blue) _state_accent="#3590BD" ;;
    slate-blue) _state_accent="#7391A5" ;;
    brown) _state_accent="#996548" ;;
    green) _state_accent="#17D174" ;;
    magenta) _state_accent="#CB17D1" ;;
    red) _state_accent="#D1174F" ;;
    yellow) _state_accent="#D1CE17" ;;
    purple) _state_accent="#9617D1" ;;
    silver) _state_accent="#595959" ;;
  esac
  case "$_state_accent" in
    \#??????|??????) printf '%s\n' "$_state_accent" ;;
    *) printf '%s\n' "$_state_default" ;;
  esac
}

select_accent() {
  _blue="$(argvus_tr appearance accent.color.blue)"
  _slate_blue="$(argvus_tr appearance accent.color.slate_blue)"
  _brown="$(argvus_tr appearance accent.color.brown)"
  _green="$(argvus_tr appearance accent.color.green)"
  _magenta="$(argvus_tr appearance accent.color.magenta)"
  _red="$(argvus_tr appearance accent.color.red)"
  _yellow="$(argvus_tr appearance accent.color.yellow)"
  _purple="$(argvus_tr appearance accent.color.purple)"
  _silver="$(argvus_tr appearance accent.color.silver)"
  rofi -config "$(paths_config launcher/config/config.rasi)" -dmenu \
    -p "$(argvus_tr appearance accent.title)" -i -theme-str 'listview {lines: 9;}' <<EOF
01 - $_blue       #3590bd
02 - $_slate_blue #7391a5
03 - $_brown      #996548
04 - $_green      #17d174
05 - $_magenta    #cb17d1
06 - $_red        #d1174f
07 - $_yellow     #d1ce17
08 - $_purple     #9617d1
09 - $_silver     #595959
EOF
}

normalize_accent() {
  _requested="$(printf '%s' "$1" | tr 'a-f' 'A-F')"
  case "$_requested" in
    \#*) _hex="${_requested#\#}" ;;
    *) _hex="$_requested" ;;
  esac
  [ "${#_hex}" -eq 6 ] || return 1
  case "$_hex" in
    *[!0-9A-F]*) return 1 ;;
  esac

  COLOR="#$_hex"
  RED="$(printf '%d' "0x${_hex%????}")"
  BLUE="$(printf '%d' "0x${_hex#????}")"
  # Extract the middle byte without relying on non-POSIX substring syntax.
  _middle="${_hex#??}"
  _middle="${_middle%??}"
  GREEN="$(printf '%d' "0x$_middle")"
  _luminance=$(( (299 * RED + 587 * GREEN + 114 * BLUE) / 1000 ))
  if [ "$_luminance" -ge 128 ]; then
    ACCENT_TEXT="#000000"
  else
    ACCENT_TEXT="#FFFFFF"
  fi
  HEX="${COLOR#\#}"
}

replace_setting() {
  _file="$1"
  _name="$2"
  _value="$3"
  [ -f "$_file" ] || return 0
  sed -i "s|^${_name}[[:space:]]*=.*|${_name} = ${_value}|" "$_file"
}

sync_snappy_switcher_theme() {
  _source_config="$(paths_config app-profiles/config/snappy-switcher/config.ini)"
  _source_theme="$(paths_config "app-profiles/config/snappy-switcher/themes/${THEME}/theme.ini")"
  _native_root="${ARGVUS_CONFIG_HOME}/snappy-switcher"
  _native_config="${_native_root}/config.ini"
  _native_theme="${_native_root}/themes/${THEME}.ini"

  [ -f "$_source_config" ] || return 0
  [ -f "$_source_theme" ] || return 0
  mkdir -p "${_native_root}/themes"
  if [ ! -f "$_native_config" ]; then
    cp "$_source_config" "$_native_config"
  fi
  sed -i "s|^[[:space:]]*name[[:space:]]*=.*|name = ${THEME}.ini|" "$_native_config"
  cp "$_source_theme" "$_native_theme"
}

sync_native_qt6ct_config() {
  _managed_qt6ct="$1"
  _native_qt6ct="${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct/qt6ct.conf"
  [ "$_native_qt6ct" = "$_managed_qt6ct" ] && return 0

  # qt6ct does not search the ARGVUS component tree below ~/.config. Keep its
  # standard per-user file in sync when it is absent or was generated by
  # ARGVUS, while leaving an unrelated native Qt6ct override untouched.
  if [ ! -f "$_native_qt6ct" ]; then
    mkdir -p "${_native_qt6ct%/*}"
    cp "$_managed_qt6ct" "$_native_qt6ct"
    return 0
  fi

  if grep -q '^icon_theme[[:space:]]*=[[:space:]]*Argvus Icons$' "$_native_qt6ct" \
    || grep -Eq '^color_scheme_path[[:space:]]*=.*(argvus|appearance/config/qt6ct)/colors/argvus-' "$_native_qt6ct"; then
    replace_setting "$_native_qt6ct" color_scheme_path \
      "$(paths_config "appearance/config/qt6ct/colors/${THEME}.conf")"
    replace_setting "$_native_qt6ct" custom_palette true
  fi
}

replace_toml_color() {
  _file="$1"
  _name="$2"
  [ -f "$_file" ] || return 0
  sed -i "s|^${_name}[[:space:]]*=.*|${_name} = \"${COLOR}\"|" "$_file"
}

set_dunst_section_value() {
  _file="$1"
  _section="$2"
  _key="$3"
  _value="$4"
  _tmp="${_file}.accent.$$"

  awk -v section="[$_section]" -v key="$_key" -v value="    $_key = \"$_value\"" '
    /^\[/ { in_section = ($0 == section) }
    in_section && $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
      print value
      next
    }
    { print }
  ' "$_file" > "$_tmp" && mv "$_tmp" "$_file"
}

apply_theme_references() {
  _yazi_config="$(paths_config app-profiles/config/yazi)"
  _superfile_config="$(paths_config app-profiles/config/superfile)"
  _rofi_config="$(paths_config launcher/config/config.rasi)"
  _rofi_theme_file="$(paths_config launcher/config/theme.rasi)"
  _rofi_mode="$(paths_config launcher/config/mode.rasi)"
  _rofi_theme="$(paths_config "launcher/config/themes/${THEME}/theme.rasi")"

  sed -i "s|@import url(\"./themes/.*/theme.css\");|@import url(\"./themes/${THEME}/theme.css\");|" \
    "$(paths_config taskbar/config/argvus-taskbar.css)" 2>/dev/null || true
  sed -i "s|@import url(\"./themes/.*/widget-telemetry-theme.css\");|@import url(\"./themes/${THEME}/widget-telemetry-theme.css\");|" \
    "$(paths_config widget-telemetry/config/argvus-widget-telemetry.css)" 2>/dev/null || true
  sed -i "s|^@theme \".*theme.rasi\"$|@theme \"${_rofi_theme_file}\"|" \
    "$_rofi_config" 2>/dev/null || true
  sed -i "s|^@import \".*themes/.*/theme.rasi\"$|@import \"${_rofi_theme}\"|" \
    "$_rofi_theme_file" 2>/dev/null || true
  sed -i "s|^@import \".*mode.rasi\"$|@import \"${_rofi_mode}\"|" \
    "$_rofi_theme_file" 2>/dev/null || true
  command -v argvus-terminal >/dev/null 2>&1 && argvus-terminal --apply "$THEME" >/dev/null 2>&1 || true
  command -v argvus-system-monitor >/dev/null 2>&1 && argvus-system-monitor --apply "$THEME" >/dev/null 2>&1 || true
  sync_snappy_switcher_theme
  replace_setting "$_superfile_config/config.toml" theme "\"${THEME}\""
  _qt6ct_conf="$(paths_config appearance/config/qt6ct/qt6ct.conf)"
  replace_setting "$_qt6ct_conf" color_scheme_path "$(paths_config "appearance/config/qt6ct/colors/${THEME}.conf")"
  sync_native_qt6ct_config "$_qt6ct_conf"
  if [ -f "$_yazi_config/flavors/${THEME}.yazi/flavor.toml" ]; then
    printf '[flavor]\ndark = "%s"\n' "$THEME" > "$_yazi_config/theme.toml"
  fi
}

apply_control_center() {
  # The appearance package owns the shared TUI palette consumed by all
  # terminal applications, including Control Center and the greeter.
  _center_source="$(paths_config "appearance/config/tui/themes/${THEME}.css")"
  [ -f "$_center_source" ] || return 0
  _center_cache="${XDG_CACHE_HOME:-$HOME/.cache}/argvus-control-center/theme.css"
  mkdir -p "${_center_cache%/*}"
  _center_temp="${_center_cache}.$$"
  # Only override accent fields. The Rust loader reads backgrounds and relative
  # imports directly from its official active theme, including Float parents.
  {
    printf '@define-color argvus_accent %s;\n' "$COLOR"
    printf '@define-color argvus_accent_alpha rgba(%s, %s, %s, 0.45);\n' "$RED" "$GREEN" "$BLUE"
  } > "$_center_temp" && mv "$_center_temp" "$_center_cache"
}

apply_waybar() {
  _theme_css="$(paths_config "taskbar/config/themes/${THEME}/theme.css")"
  _widget_telemetry_css="$(paths_config "widget-telemetry/config/themes/${THEME}/widget-telemetry-theme.css")"
  [ -f "$_theme_css" ] && sed -i \
    -e "s|^@define-color th-decorate .*|@define-color th-decorate        ${COLOR};|" \
    -e "s|^@define-color th-decorate-rgba .*|@define-color th-decorate-rgba   rgba(${RED}, ${GREEN}, ${BLUE}, 0.45);|" \
    -e "s|^@define-color th-border-rights .*|@define-color th-border-rights   rgba(${RED}, ${GREEN}, ${BLUE}, 0.25);|" \
    -e "s|^@define-color th-power .*|@define-color th-power           ${COLOR};|" \
    -e "s|^@define-color th-mpris-border .*|@define-color th-mpris-border    rgba(${RED}, ${GREEN}, ${BLUE}, 0.25);|" \
    "$_theme_css"
  [ -f "$_widget_telemetry_css" ] && sed -i \
    -e "s|^@define-color th-header .*|@define-color th-header        ${COLOR};|" \
    -e "s|^@define-color th-border .*|@define-color th-border        rgba(${RED}, ${GREEN}, ${BLUE}, 0.15);|" \
    -e "s|^@define-color th-border-header .*|@define-color th-border-header rgba(${RED}, ${GREEN}, ${BLUE}, 0.20);|" \
    "$_widget_telemetry_css"
}

apply_rofi() {
  _file="$(paths_config "launcher/config/themes/${THEME}/theme.rasi")"
  [ -f "$_file" ] || return 0
  sed -i \
    -e "s|^[[:space:]]*th-fg:.*|    th-fg:            rgb(${RED}, ${GREEN}, ${BLUE});|" \
    -e "s|^[[:space:]]*th-row-alt:.*|    th-row-alt:       rgba(${RED}, ${GREEN}, ${BLUE}, 7%);|" \
    -e "s|^[[:space:]]*th-border-color:.*|    th-border-color:  rgba(${RED}, ${GREEN}, ${BLUE}, 0.36);|" \
    "$_file"
}

apply_qt_palette() {
  _file="$(paths_config "appearance/config/qt6ct/colors/${THEME}.conf")"
  [ -f "$_file" ] || return 0
  _tmp="${_file}.accent.$$"
  awk -v accent="#ff${HEX}" '
    /^(active_colors|disabled_colors|inactive_colors)=/ {
      equals = index($0, "=")
      prefix = substr($0, 1, equals)
      count = split(substr($0, equals + 1), colors, ", ")
      colors[3] = accent; colors[8] = accent; colors[13] = accent; colors[16] = accent
      printf "%s", prefix
      for (i = 1; i <= count; i++) printf "%s%s", (i > 1 ? ", " : ""), colors[i]
      printf "\n"
      next
    }
    { print }
  ' "$_file" > "$_tmp" && mv "$_tmp" "$_file"
}

apply_quickshell() {
  _file="$(paths_config "control-panel/config/quickshell/argvus-control-panel/themes/${THEME}/Theme.qml")"
  [ -f "$_file" ] || return 0
  sed -i \
    -e "s|^[[:space:]]*readonly property color accent:.*|    readonly property color accent:          \"${COLOR}\"|" \
    -e "s|^[[:space:]]*readonly property color accentDim:.*|    readonly property color accentDim:       \"#22${HEX}\"|" \
    -e "s|^[[:space:]]*readonly property color accentMid:.*|    readonly property color accentMid:       \"#55${HEX}\"|" \
    -e "s|^[[:space:]]*readonly property color accentFaint:.*|    readonly property color accentFaint:     \"#0f${HEX}\"|" \
    -e "s|^[[:space:]]*readonly property color accentLight:.*|    readonly property color accentLight:     \"${COLOR}\"|" \
    -e "s|^[[:space:]]*readonly property color fgTitle:.*|    readonly property color fgTitle:         \"${COLOR}\"|" \
    -e "s|^[[:space:]]*readonly property color fgOnAccent:.*|    readonly property color fgOnAccent:      \"${ACCENT_TEXT}\"|" \
    -e "s|^[[:space:]]*readonly property color bgActive:.*|    readonly property color bgActive:        \"#22${HEX}\"|" \
    -e "s|^[[:space:]]*readonly property color border:.*|    readonly property color border:          \"#22${HEX}\"|" \
    -e "s|^[[:space:]]*readonly property color borderStrong:.*|    readonly property color borderStrong:    \"#55${HEX}\"|" \
    -e "s|^[[:space:]]*readonly property color borderItem:.*|    readonly property color borderItem:      \"#0f${HEX}\"|" \
    "$_file"
}

apply_application_colors() {
  _hyprlock="$(paths_config lock/config/hyprlock.conf)"
  _hyprtoolkit="$(paths_config appearance/config/hypr/hyprtoolkit.conf)"
  _dunst="$(paths_config notifications/config/dunstrc)"
  _foot="$(paths_config app-profiles/config/foot/foot.ini)"
  sync_snappy_switcher_theme
  _snappy="${ARGVUS_CONFIG_HOME}/snappy-switcher/themes/${THEME}.ini"
  _yazi="$(paths_config "app-profiles/config/yazi/flavors/${THEME}.yazi/flavor.toml")"
  _superfile="$(paths_config "app-profiles/config/superfile/theme/${THEME}.toml")"

  [ -f "$_hyprlock" ] && sed -i "s|^[[:space:]]*outer_color = .*|  outer_color = rgb(${HEX})|" "$_hyprlock"
  [ -f "$_hyprtoolkit" ] && sed -i \
    -e "s|^bright_text = .*|bright_text = 0xFF${HEX}|" \
    -e "s|^accent = .*|accent = 0xFF${HEX}|" \
    -e "s|^link_text = .*|link_text = 0xFF${HEX}|" "$_hyprtoolkit"
  if [ -f "$_dunst" ]; then
    for _section in global urgency_low urgency_normal urgency_critical hyprshot volume gpu-screen-recorder network spotify discord; do
      set_dunst_section_value "$_dunst" "$_section" frame_color "$COLOR"
      set_dunst_section_value "$_dunst" "$_section" highlight "$COLOR"
    done
  fi
  [ -f "$_foot" ] && sed -i "s|^[[:space:]]*border-color=.*|border-color=${HEX}ff|" "$_foot"
  _native_foot="${ARGVUS_CONFIG_HOME}/foot/foot.ini"
  if [ -f "$_native_foot" ] && grep -q 'argvus.*/foot/themes' "$_native_foot"; then
    sed -i "s|^[[:space:]]*border-color=.*|border-color=${HEX}ff|" "$_native_foot"
  fi
  [ -f "$_snappy" ] && sed -i \
    -e "s|^border_color .*|border_color  = ${COLOR}ff|" \
    -e "s|^badge_bg .*|badge_bg      = ${COLOR}ff|" "$_snappy"

  if [ -f "$_yazi" ]; then
    _old_yazi_accent="$(theme_default_accent "$THEME" 2>/dev/null || true)"
    if [ -n "$_old_yazi_accent" ]; then
      _old_yazi_hex="${_old_yazi_accent#\#}"
      sed -i "s|#${_old_yazi_hex}|${COLOR}|gI" "$_yazi"
    fi
  fi

  command -v argvus-system-monitor >/dev/null 2>&1 && argvus-system-monitor --apply "$THEME" >/dev/null 2>&1 || true

  for _key in file_panel_border_active file_panel_top_directory_icon footer_border_active sidebar_title sidebar_border_active modal_border_active modal_confirm_bg help_menu_hotkey correct hint; do
    replace_toml_color "$_superfile" "$_key"
  done
  [ -f "$_superfile" ] && sed -i \
    -e "s|^gradient_color = \[\"#[0-9A-Fa-f]*\",|gradient_color = [\"${COLOR}\",|" \
    -e "s|^modal_confirm_fg = .*|modal_confirm_fg = \"${ACCENT_TEXT}\"|" "$_superfile"
  _native_superfile="${ARGVUS_CONFIG_HOME}/superfile"
  if [ -f "$_superfile" ] && [ -f "$_native_superfile/config.toml" ] && [ -d "$_native_superfile/theme" ]; then
    cp "$_superfile" "$_native_superfile/theme/${THEME}.toml"
  fi
}

publish_greeter_accent() {
  [ -d "$GREETER_THEME_STATE_DIR" ] || return 0

  _greeter_accent_uid="$(id -u)"
  _greeter_accent_target="$GREETER_THEME_STATE_DIR/$_greeter_accent_uid.accent"
  _greeter_accent_tmp="${_greeter_accent_target}.tmp.$$"
  if ! printf '%s\n' "$COLOR" > "$_greeter_accent_tmp"; then
    rm -f -- "$_greeter_accent_tmp"
    return 0
  fi
  chmod 0644 "$_greeter_accent_tmp" 2>/dev/null || true
  if ! mv -f -- "$_greeter_accent_tmp" "$_greeter_accent_target"; then
    rm -f -- "$_greeter_accent_tmp"
  fi
}

refresh_runtime() {
  command -v hyprctl >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1 || true
  command -v argvus-terminal >/dev/null 2>&1 && argvus-terminal --apply "$THEME" >/dev/null 2>&1 || true
  if [ "${ARGVUS_THEME_SWITCH:-0}" != 1 ]; then
    argvus-sessionctl restart waybar dunst snappy-switcher shell >/dev/null 2>&1 || true
  fi
  # Signal running kitty instances to reload config (SIGUSR1)
  for _pid in $(pgrep -x kitty 2>/dev/null); do
    kill -USR1 "$_pid" 2>/dev/null || true
  done
}

case "${1:-}" in
  --startup) RUNTIME=0; NOTIFY=0; REQUESTED="$(read_accent_state)" ;;
  --apply) NOTIFY=0; REQUESTED="$(read_accent_state)" ;;
  --apply-static) RUNTIME=0; NOTIFY=0; REQUESTED="$(read_accent_state)" ;;
  --theme-default)
    RUNTIME=0
    NOTIFY=0
    _active_theme="$(canonical_theme_id "$(read_state "$ACTIVE_FILE" "$DEFAULT_THEME")")"
    if ! REQUESTED="$(theme_default_accent "$_active_theme")"; then
      argvus_tr appearance accent.default_missing "theme=$_active_theme" >&2
      exit 1
    fi
    ;;
  '') REQUESTED="$(select_accent)"; [ -n "$REQUESTED" ] || exit 0 ;;
  *) REQUESTED="$1" ;;
esac

if [ "${ARGVUS_NO_RUNTIME:-0}" = 1 ]; then
  RUNTIME=0
  NOTIFY=0
fi

if ! normalize_accent "$REQUESTED"; then
  argvus_tr appearance accent.invalid "value=$REQUESTED" >&2
  exit 1
fi

THEME="$(canonical_theme_id "$(read_state "$ACTIVE_FILE" "$DEFAULT_THEME")")"
case "$THEME" in
  one-dark|one-dark-float|dracula|dracula-float|argvus-dark|argvus-dark-float|silver-dark|silver-dark-float|argvus-light|argvus-light-float|github-light|github-light-float|solarized-light|solarized-light-float|one-light|one-light-float|everforest-light|everforest-light-float|frost|frost-float|catppuccin-latte|catppuccin-latte-float|gruvbox-light|gruvbox-light-float|slate-dark|slate-dark-float|universe|universe-float|gruvbox-high-dark|gruvbox-high-dark-float|gruvbox-dark|gruvbox-dark-float|rose-pine|rose-pine-float|tokyo-night|tokyo-night-float|solitude|solitude-float|sunset|sunset-float|hackerman|hackerman-float|monokai-dark|monokai-dark-float) ;;
  *-dark-float) THEME="argvus-dark-float" ;;
  *-light-float) THEME="argvus-light-float" ;;
  *-light) THEME="argvus-light" ;;
  *) THEME="$DEFAULT_THEME" ;;
esac

mkdir -p "$STATE_DIR"
printf '%s\n' "$THEME" > "$ACTIVE_FILE"
printf '%s\n' "$COLOR" > "$ACCENT_FILE"
publish_greeter_accent

apply_theme_references
apply_waybar
apply_control_center
apply_rofi
apply_qt_palette
apply_quickshell
apply_application_colors

[ "$RUNTIME" -eq 1 ] && refresh_runtime
if [ "$NOTIFY" -eq 1 ]; then
  notify-send "$(argvus_tr appearance accent.notification.title)" \
    "$(argvus_tr appearance accent.notification.message "color=$COLOR")" 2>/dev/null || true
fi
argvus_tr appearance accent.applied "color=$COLOR" "theme=$THEME"
