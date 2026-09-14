#!/usr/bin/env sh
# theme-switch - apply a named theme across the whole argvus desktop
# Usage: theme-switch <theme-name>
# shellcheck disable=SC1090,SC1091,SC2034

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

# Wallpaper runtime helpers live with the appearance component. Load them
# explicitly; bootstrap only provides shared session APIs and does not
# implicitly source appearance-owned scripts.
ARGVUS_HYPR_HELPER="${ARGVUS_SYSTEM_CONFIG}/appearance/sh/hypr.sh"
[ -r "$ARGVUS_HYPR_HELPER" ] && . "$ARGVUS_HYPR_HELPER"

ARGVUS_MUTABLE_CONFIG=1
export ARGVUS_THEME_SWITCH=1

THEME="${1:-}"
ACTIVE_FILE="${ARGVUS_CONFIG_HOME}/argvus/.active-theme"
RUNTIME=1
mkdir -p "${ACTIVE_FILE%/*}"
# Development-only sibling lookup, relative to the migrated source layout.
_source_root="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
case "$_source_root" in
  */src/usr/share/argvus/appearance/sh)
    _appearance_root="${_source_root%/src/usr/share/argvus/appearance/sh}"
    _workspace_root="${_appearance_root%/*}"
    ;;
  *) _workspace_root="" ;;
esac

if [ "${ARGVUS_NO_RUNTIME:-0}" = 1 ]; then
  RUNTIME=0
fi

if [ -z "$THEME" ]; then
  THEME=$(
    rofi -config "$(paths_config launcher/config/config.rasi)" -dmenu -p "   Select Theme" -i -theme-str 'listview {lines: 10;}' <<'EOF'
01 - Argvus Dark Aether
02 - Argvus Dark Aether Float
03 - Argvus Dark Silver
04 - Argvus Dark Silver Float
05 - Argvus Dark Slate
06 - Argvus Dark Slate Float
07 - Argvus Dark Universe
08 - Argvus Dark Universe Float
09 - Argvus Light Veil
10 - Argvus Light Veil Float
EOF
  )

  [ -z "$THEME" ] && exit 0

  case "$THEME" in
    "01 - Argvus Dark Aether")       THEME="argvus-dark-aether" ;;
    "02 - Argvus Dark Aether Float") THEME="argvus-dark-aether-float" ;;
    "03 - Argvus Dark Silver")       THEME="argvus-dark-silver" ;;
    "04 - Argvus Dark Silver Float") THEME="argvus-dark-silver-float" ;;
    "05 - Argvus Dark Slate")        THEME="argvus-dark-slate" ;;
    "06 - Argvus Dark Slate Float")  THEME="argvus-dark-slate-float" ;;
    "07 - Argvus Dark Universe")     THEME="argvus-dark-universe" ;;
    "08 - Argvus Dark Universe Float") THEME="argvus-dark-universe-float" ;;
    "09 - Argvus Light Veil")        THEME="argvus-light-veil" ;;
    "10 - Argvus Light Veil Float")  THEME="argvus-light-veil-float" ;;
    *) printf 'Invalid theme selection\n' >&2; exit 1 ;;
  esac
fi

# Serialize the complete transaction, including cleanup. Close the lock FD in
# children so a wallpaper process cannot keep the next theme switch blocked.
if [ "${ARGVUS_THEME_LOCKED:-0}" != 1 ]; then
  _theme_lock="$(paths_cache theme-switch.lock)"
  mkdir -p "${_theme_lock%/*}"
  exec env ARGVUS_THEME_LOCKED=1 flock --exclusive --close "$_theme_lock" sh "$0" "$THEME"
fi

ensure_theme_parent() {
  _relative="$1"
  _theme="$2"
  _target="$(paths_user_config "${_relative}/${_theme}")"

  # Taskbar and telemetry share the legacy user waybar/themes directory.
  # An existing directory does not imply that this component's files exist.
  # Fill missing files while preserving existing user edits and overrides.
  for _source in \
    "$(paths_override_config "${_relative}/${_theme}")" \
    "$(paths_generated_config "${_relative}/${_theme}")" \
    "$(paths_system_config "${_relative}/${_theme}")"; do
    [ "$_source" = "$_target" ] && continue
    if [ -d "$_source" ]; then
      mkdir -p "$_target"
      cp -R --update=none "$_source/." "$_target/" || return 1
    fi
  done

  [ -d "$_target" ] || return 1
  dirname "$_target"
}

required_theme_parent() {
  _relative="$1"
  _theme="$2"

  if ! ensure_theme_parent "$_relative" "$_theme"; then
    printf 'Error: theme directory not found: %s\n' "$(paths_system_config "${_relative}/${_theme}")" >&2
    exit 1
  fi
}

optional_theme_parent() {
  _relative="$1"
  _theme="$2"

  if ensure_theme_parent "$_relative" "$_theme"; then
    return 0
  fi

  paths_config "$_relative"
}

ensure_theme_file_parent() {
  _relative="$1"
  _file="$2"
  _target="$(paths_user_config "${_relative}/${_file}")"

  if [ -f "$_target" ]; then
    dirname "$_target"
    return 0
  fi

  for _source in \
    "$(paths_override_config "${_relative}/${_file}")" \
    "$(paths_generated_config "${_relative}/${_file}")" \
    "$(paths_system_config "${_relative}/${_file}")"; do
    [ "$_source" = "$_target" ] && continue
    if [ -f "$_source" ]; then
      mkdir -p "${_target%/*}"
      cp "$_source" "$_target"
      dirname "$_target"
      return 0
    fi
  done

  return 1
}

optional_theme_file_parent() {
  _relative="$1"
  _file="$2"

  if ensure_theme_file_parent "$_relative" "$_file"; then
    return 0
  fi

  paths_config "$_relative"
}

replace_or_append_setting() {
  _file="$1"
  _key="$2"
  _value="$3"
  [ -f "$_file" ] || return 0

  if grep -q "^[[:space:]]*${_key}[[:space:]]*=" "$_file"; then
    sed -i "s|^[[:space:]]*${_key}[[:space:]]*=.*|${_key} = ${_value}|" "$_file"
  else
    printf '\n%s = %s\n' "$_key" "$_value" >> "$_file"
  fi
}

replace_or_append_ini_setting() {
  _file="$1"
  _key="$2"
  _value="$3"
  mkdir -p "${_file%/*}"
  [ -f "$_file" ] || printf '[Settings]\n' > "$_file"

  if ! grep -q '^\[Settings\]' "$_file"; then
    _tmp="${_file}.argvus.$$"
    { printf '[Settings]\n'; cat "$_file"; } > "$_tmp"
    mv "$_tmp" "$_file"
  fi

  if grep -q "^[[:space:]]*${_key}[[:space:]]*=" "$_file"; then
    sed -i "s|^[[:space:]]*${_key}[[:space:]]*=.*|${_key}=${_value}|" "$_file"
  else
    printf '%s=%s\n' "$_key" "$_value" >> "$_file"
  fi
}

font_state_value() {
  _key="$1"
  _fallback="$2"
  _fonts_file="${ARGVUS_CONFIG_HOME}/argvus/fonts.conf"
  if [ -f "$_fonts_file" ]; then
    _value="$(sed -n "s|^${_key}=||p" "$_fonts_file" | head -n1)"
    [ -n "$_value" ] && { printf '%s\n' "$_value"; return 0; }
  fi
  printf '%s\n' "$_fallback"
}

write_managed_css_block() {
  _file="$1"
  _block="$2"
  _start="/* argvus-control-center-fonts:start */"
  _end="/* argvus-control-center-fonts:end */"
  _legacy_start="/* argvus-settings-fonts:start */"
  _legacy_end="/* argvus-settings-fonts:end */"
  [ -f "$_file" ] || return 0

  if grep -qF "$_start" "$_file"; then
    awk -v start="$_start" -v end="$_end" -v block="$_block" '
      $0 == start { print start; print block; skip = 1; next }
      $0 == end { print end; skip = 0; next }
      skip { next }
      { print }
    ' "$_file" > "${_file}.argvus-fonts.$$" && mv "${_file}.argvus-fonts.$$" "$_file"
  elif grep -qF "$_legacy_start" "$_file"; then
    awk -v start="$_legacy_start" -v end="$_legacy_end" -v new_start="$_start" -v new_end="$_end" -v block="$_block" '
      $0 == start { print new_start; print block; skip = 1; next }
      $0 == end { print new_end; skip = 0; next }
      skip { next }
      { print }
    ' "$_file" > "${_file}.argvus-fonts.$$" && mv "${_file}.argvus-fonts.$$" "$_file"
  else
    {
      printf '\n%s\n' "$_start"
      printf '%s\n' "$_block"
      printf '%s\n' "$_end"
    } >> "$_file"
  fi
}

ARGVUS_APPS_NAME="$(font_state_value apps_name "$(font_state_value default_name "IBM Plex Mono")")"
ARGVUS_APPS_SIZE="$(font_state_value apps_size "$(font_state_value default_size 12)")"
ARGVUS_APPS_FONT="${ARGVUS_APPS_NAME} ${ARGVUS_APPS_SIZE}"
ARGVUS_TASKBAR_FAMILY="$(font_state_value taskbar_family "$(font_state_value default_family "IBM Plex Mono")")"
ARGVUS_TASKBAR_SIZE="$(font_state_value taskbar_size "$(font_state_value default_size 13)")"
ARGVUS_SYSINFO_FAMILY="$(font_state_value sysinfo_family "$(font_state_value monospace_family "IBM Plex Mono")")"
ARGVUS_SYSINFO_SIZE="$(font_state_value sysinfo_size "$(font_state_value monospace_size 14)")"
ARGVUS_SYSTEM_FAMILY="$(font_state_value system_family "$(font_state_value default_family "IBM Plex Mono")")"
ARGVUS_SYSTEM_SIZE="$(font_state_value system_size "$(font_state_value default_size 13)")"
ARGVUS_TERMINAL_FAMILY="$(font_state_value terminal_family "$(font_state_value monospace_family "IBM Plex Mono")")"
ARGVUS_TERMINAL_SIZE="$(font_state_value terminal_size "$(font_state_value monospace_size 13)")"

native_config_home() {
  printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}"
}

# A theme switch rewrites several live surfaces and also reloads applications
# such as Kitty.  DPMS is the compositor-level blackout: it hides existing
# windows as well as ARGVUS layers, so no intermediate palette is visible.
# Services are stopped while the display is blank and restarted only after all
# configuration, wallpaper, and runtime reloads have completed.
THEME_TRANSITION_ACTIVE=0
THEME_DISPLAY_BLANKED=0
THEME_CONFIG_READY=0

theme_transition_cleanup() {
  _status="${1:-0}"
  trap - EXIT HUP INT TERM

  if [ "$THEME_TRANSITION_ACTIVE" -eq 1 ]; then
    # Reuse the exact lifecycle behind SUPER + Shift + R. It owns config
    # synchronization and the complete service list, including idle and polkit.
    if ! argvus-sessionctl reload; then
      printf 'Error: global session reload failed after theme application.\n' >&2
      [ "$_status" -ne 0 ] || _status=1
    fi
    THEME_TRANSITION_ACTIVE=0
  fi

  if [ "$THEME_DISPLAY_BLANKED" -eq 1 ]; then
    sleep 0.25
    hyprctl eval 'hl.dispatch(hl.dsp.dpms({ action = "on" }))' >/dev/null 2>&1 || true
  fi

  if [ "$_status" -eq 0 ] && [ "$THEME_CONFIG_READY" -eq 1 ]; then
    notify-send "Theme" "Switched to '${THEME}'" 2>/dev/null || true
    printf "Theme '%s' applied.\n" "$THEME"
  fi

  exit "$_status"
}

theme_transition_begin() {
  [ "$RUNTIME" -eq 1 ] || return 0
  trap 'theme_transition_cleanup "$?"' EXIT
  trap 'exit 129' HUP
  trap 'exit 130' INT
  trap 'exit 143' TERM
  THEME_TRANSITION_ACTIVE=1
  if hyprctl eval 'hl.dispatch(hl.dsp.dpms({ action = "off" }))' >/dev/null 2>&1; then
    THEME_DISPLAY_BLANKED=1
  else
    printf 'Warning: could not blank displays; applying theme with component restart.\n' >&2
  fi

  for _unit in \
    argvus-taskbar.service \
    argvus-widget-telemetry.service \
    argvus-control-panel.service \
    argvus-dunst.service \
    argvus-snappy-switcher.service \
    argvus-wallpaper.service; do
    systemctl --user stop "$_unit" >/dev/null 2>&1 || true
  done
}

refresh_managed_waybar_file() {
  _relative_path="$1"
  _system_path="$(paths_system_config "$_relative_path")"
  _managed_path="$(paths_user_config "$_relative_path")"

  [ -f "$_system_path" ] || return 0
  mkdir -p "${_managed_path%/*}"
  cp "$_system_path" "$_managed_path"
}

gtk_theme_name_for_theme() {
  case "$1" in
    argvus-light-veil|argvus-light-veil-float) printf '%s\n' "Adwaita" ;;
    argvus-dark-*) printf '%s\n' "Adwaita-dark" ;;
    *) return 1 ;;
  esac
}

apply_gtk_runtime_settings() {
  _scheme="$1"
  _theme_name="$2"
  _fallback_theme="$3"

  [ "$RUNTIME" -eq 1 ] || return 0

  command -v gsettings >/dev/null 2>&1 || return 0

  gsettings set org.gnome.desktop.interface color-scheme "$_scheme" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface font-name "$ARGVUS_APPS_FONT" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface document-font-name "$ARGVUS_APPS_FONT" 2>/dev/null || true
  _current_theme="$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || true)"
  if [ "$_current_theme" = "'${_theme_name}'" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "$_fallback_theme" 2>/dev/null || true
    sleep 0.05
  fi
  gsettings set org.gnome.desktop.interface gtk-theme "$_theme_name" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface icon-theme "Argvus Icons" 2>/dev/null || true
}

apply_gtk_theme_files() {
  _gtk_mode="$1"
  _gtk_theme_name="$2"
  _prefer_dark="$3"

  for _gtk_version in gtk-3.0 gtk-4.0; do
    _theme_dir="$(optional_theme_parent "appearance/config/${_gtk_version}/themes" "$THEME")"

    _argvus_gtk_dir="$(paths_user_config "$_gtk_version")"
    _native_gtk_dir="$(native_config_home)/${_gtk_version}"
    mkdir -p "$_argvus_gtk_dir" "$_native_gtk_dir"

    if [ -f "${_theme_dir}/${THEME}/gtk.css" ]; then
      cp "${_theme_dir}/${THEME}/gtk.css" "${_argvus_gtk_dir}/gtk.css"
    fi

    if [ -f "${_theme_dir}/${THEME}/gtk-dark.css" ]; then
      cp "${_theme_dir}/${THEME}/gtk-dark.css" "${_argvus_gtk_dir}/gtk-dark.css"
    fi

    for _settings in "${_argvus_gtk_dir}/settings.ini" "${_native_gtk_dir}/settings.ini"; do
      replace_or_append_ini_setting "$_settings" gtk-theme-name "$_gtk_theme_name"
      replace_or_append_ini_setting "$_settings" gtk-application-prefer-dark-theme "$_prefer_dark"
      replace_or_append_ini_setting "$_settings" gtk-icon-theme-name "Argvus Icons"
      replace_or_append_ini_setting "$_settings" gtk-font-name "$ARGVUS_APPS_FONT"
      replace_or_append_ini_setting "$_settings" gtk-cursor-theme-name Adwaita
      replace_or_append_ini_setting "$_settings" gtk-cursor-theme-size 24
    done
  done

  printf '%s\n' "$_gtk_mode" > "$GTK_MODE_FILE"
}

HYPR_THEMES="$(required_theme_parent appearance/config/hypr/themes "$THEME")"
WAYBAR_THEMES="$(optional_theme_parent taskbar/config/themes "$THEME")"
optional_theme_parent widget-telemetry/config/themes "$THEME" >/dev/null
QS_THEMES="$(optional_theme_parent control-panel/config/quickshell/argvus-control-panel/themes "$THEME")"
ROFI_THEMES="$(optional_theme_parent launcher/config/themes "$THEME")"
ROFI_CONFIG="$(paths_config launcher/config/config.rasi)"
ROFI_THEME="$(paths_config launcher/config/theme.rasi)"
ROFI_MODE="$(paths_config launcher/config/mode.rasi)"
DUNST_THEMES="$(optional_theme_parent notifications/config/themes "$THEME")"
FOOT_CONFIG="$(paths_config app-profiles/config/foot/foot.ini)"
FOOT_THEMES="$(optional_theme_parent app-profiles/config/foot/themes "$THEME")"
FOOT_SYSTEM_THEMES="$(paths_system_config app-profiles/config/foot/themes)"
YAZI_CONFIG_ROOT="$(paths_config app-profiles/config/yazi)"
YAZI_SYSTEM_ROOT="$(paths_system_config app-profiles/config/yazi)"
SNAPPY_THEMES="$(optional_theme_parent app-profiles/config/snappy-switcher/themes "$THEME")"
SUPERFILE_CONFIG_ROOT="$(paths_config app-profiles/config/superfile)"
SUPERFILE_THEMES="$(optional_theme_file_parent app-profiles/config/superfile/theme "${THEME}.toml")"
QT6CT_COLORS="$(paths_config appearance/config/qt6ct/colors)"
HYPRPAPER_FILE="$(paths_config appearance/config/hypr/hyprpaper.conf)"
HYPRPAPER_DIR="$(paths_backgrounds argvus)"

apply_wallpaper_runtime() {
  _wall="$1"
  [ "$RUNTIME" -eq 1 ] || return 0
  # The central reload starts the wallpaper after every config is ready.
  systemctl --user set-environment WALLPAPER_PATH="$_wall"
}

get_active_monitor() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl monitors 2>/dev/null |
      sed -n 's/^Monitor \([^ ]*\).*/\1/p' |
      head -n1
  fi
}

find_theme_wallpaper() {
  _theme="$1"

  case "$_theme" in
    argvus-dark-aether|argvus-dark-aether-float) _wall_name="default.png" ;;
    argvus-dark-silver|argvus-dark-silver-float) _wall_name="argvus-dark-silver.png" ;;
    argvus-light-veil|argvus-light-veil-float) _wall_name="argvus-light-veil.png" ;;
    argvus-dark-slate|argvus-dark-slate-float) _wall_name="argvus-dark-slate.png" ;;
    argvus-dark-universe|argvus-dark-universe-float) _wall_name="argvus-dark-universe.png" ;;
    *) _wall_name="" ;;
  esac

  if [ -n "$_wall_name" ]; then
    _wall="${HYPRPAPER_DIR}/${_wall_name}"
    if [ ! -f "$_wall" ]; then
      printf 'Error: wallpaper not found: %s\n' "$_wall" >&2
      return 1
    fi
    printf '%s\n' "$_wall"
    return 0
  fi

  for _ext in jpeg jpg png webp; do
    _wall="${HYPR_THEMES}/${_theme}/wallpaper.${_ext}"
    [ -f "$_wall" ] && { printf '%s\n' "$_wall"; return 0; }

    _wall="${HYPRPAPER_DIR}/${_theme}.${_ext}"
    [ -f "$_wall" ] && { printf '%s\n' "$_wall"; return 0; }
  done

  # Backward compatibility for older assets with display-case names.
  find "$HYPRPAPER_DIR" -maxdepth 1 -type f -iname "${_theme}.*" | head -n1
}

theme_value() {
  _file="$1"
  _name="$2"
  _fallback="$3"

  if [ -f "$_file" ]; then
    _value=$(sed -n "s|^${_name}[[:space:]]*=[[:space:]]*\"\\{0,1\\}\\([^\" ]*\\)\"\\{0,1\\}.*|\\1|p" "$_file" | head -n1)
    [ -n "$_value" ] && { printf '%s\n' "$_value"; return 0; }
  fi

  printf '%s\n' "$_fallback"
}

set_dunst_section_value() {
  _file="$1"
  _section="$2"
  _key="$3"
  _value="$4"
  _tmp="${_file}.theme.$$"

  awk -v section="[$_section]" -v key="$_key" -v value="    $_key = \"$_value\"" '
    /^\[/ { in_section = ($0 == section) }
    in_section && $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
      print value
      next
    }
    { print }
  ' "$_file" > "$_tmp" && mv "$_tmp" "$_file"
}

should_manage_foot_config() {
  _conf="$1"
  [ -f "$_conf" ] || return 0
  grep -q 'argvus.*/foot/themes' "$_conf"
}

foot_color_value() {
  _file="$1"
  _key="$2"
  sed -n "s|^[[:space:]]*${_key}[[:space:]]*=[[:space:]]*\\([0-9A-Fa-f][0-9A-Fa-f ]*\\).*|\\1|p" "$_file" | head -n1
}

send_foot_palette_to_pty() {
  _tty="$1"
  _theme_file="$2"
  [ -w "$_tty" ] || return 0

  _fg="$(foot_color_value "$_theme_file" foreground)"
  _bg="$(foot_color_value "$_theme_file" background)"
  _sel_fg="$(foot_color_value "$_theme_file" selection-foreground)"
  _sel_bg="$(foot_color_value "$_theme_file" selection-background)"
  _cursor="$(foot_color_value "$_theme_file" cursor | awk '{print $2}')"

  {
    [ -n "$_fg" ] && printf '\033]10;#%s\a' "$_fg"
    [ -n "$_bg" ] && printf '\033]11;#%s\a' "$_bg"
    [ -n "$_cursor" ] && printf '\033]12;#%s\a' "$_cursor"
    [ -n "$_sel_bg" ] && printf '\033]17;#%s\a' "$_sel_bg"
    [ -n "$_sel_fg" ] && printf '\033]19;#%s\a' "$_sel_fg"

    _idx=0
    for _key in regular0 regular1 regular2 regular3 regular4 regular5 regular6 regular7 \
      bright0 bright1 bright2 bright3 bright4 bright5 bright6 bright7; do
      _value="$(foot_color_value "$_theme_file" "$_key")"
      [ -n "$_value" ] && printf '\033]4;%s;#%s\a' "$_idx" "$_value"
      _idx=$((_idx + 1))
    done
  } > "$_tty" 2>/dev/null || true
}

apply_running_foot_theme() {
  _theme_file="$1"
  [ "$RUNTIME" -eq 1 ] || return 0
  [ -f "$_theme_file" ] || return 0

  for _pid in $(pgrep -x foot 2>/dev/null) $(pgrep -x footclient 2>/dev/null); do
    for _fd in 0 1 2; do
      _tty="$(readlink "/proc/$_pid/fd/$_fd" 2>/dev/null || true)"
      case "$_tty" in
        /dev/pts/*|/dev/tty*) send_foot_palette_to_pty "$_tty" "$_theme_file" ;;
      esac
    done

    for _child in $(pgrep -P "$_pid" 2>/dev/null); do
      for _fd in 0 1 2; do
        _tty="$(readlink "/proc/$_child/fd/$_fd" 2>/dev/null || true)"
        case "$_tty" in
          /dev/pts/*|/dev/tty*) send_foot_palette_to_pty "$_tty" "$_theme_file" ;;
        esac
      done
    done
  done
}

apply_dunst_theme() {
  _theme_file="$DUNST_THEMES/$THEME/dunstrc.theme"
  _dunstrc="$(paths_config notifications/config/dunstrc)"
  [ -f "$_theme_file" ] && [ -f "$_dunstrc" ] || return 0

  _highlight=$(theme_value "$_theme_file" highlight "#3590bd")
  _frame=$(theme_value "$_theme_file" frame_color "$_highlight")
  _low_bg=$(theme_value "$_theme_file" low_background "#101010")
  _low_fg=$(theme_value "$_theme_file" low_foreground "#aaaaaa")
  _normal_bg=$(theme_value "$_theme_file" normal_background "$_low_bg")
  _normal_fg=$(theme_value "$_theme_file" normal_foreground "$_low_fg")
  _critical_bg=$(theme_value "$_theme_file" critical_background "$_normal_bg")
  _critical_fg=$(theme_value "$_theme_file" critical_foreground "$_normal_fg")
  _app_bg=$(theme_value "$_theme_file" app_background "$_normal_bg")
  _app_fg=$(theme_value "$_theme_file" app_foreground "$_normal_fg")

  set_dunst_section_value "$_dunstrc" global highlight "$_highlight"
  set_dunst_section_value "$_dunstrc" global frame_color "$_frame"

  set_dunst_section_value "$_dunstrc" urgency_low background "$_low_bg"
  set_dunst_section_value "$_dunstrc" urgency_low foreground "$_low_fg"
  set_dunst_section_value "$_dunstrc" urgency_low frame_color "$_frame"

  set_dunst_section_value "$_dunstrc" urgency_normal background "$_normal_bg"
  set_dunst_section_value "$_dunstrc" urgency_normal foreground "$_normal_fg"
  set_dunst_section_value "$_dunstrc" urgency_normal frame_color "$_frame"

  set_dunst_section_value "$_dunstrc" urgency_critical background "$_critical_bg"
  set_dunst_section_value "$_dunstrc" urgency_critical foreground "$_critical_fg"
  set_dunst_section_value "$_dunstrc" urgency_critical frame_color "$_frame"
  set_dunst_section_value "$_dunstrc" urgency_critical highlight "$_highlight"

  for _section in hyprshot volume gpu-screen-recorder network spotify discord; do
    set_dunst_section_value "$_dunstrc" "$_section" background "$_app_bg"
    set_dunst_section_value "$_dunstrc" "$_section" foreground "$_app_fg"
    set_dunst_section_value "$_dunstrc" "$_section" frame_color "$_frame"
    set_dunst_section_value "$_dunstrc" "$_section" highlight "$_highlight"
  done
}

apply_wallpaper() {
  _wall="$1"
  [ -z "$_wall" ] && return 0

  _config_path=$(printf '%s\n' "$_wall" | sed "s|^$HOME|~|")
  _monitor="$(get_active_monitor)"

  if [ -n "$_monitor" ]; then
    sed -i "s|^[[:space:]]*monitor[[:space:]]*=.*$|  monitor = ${_monitor}|" "$HYPRPAPER_FILE"
  fi

  sed -i "s|^[[:space:]]*path[[:space:]]*=.*$|  path =  ${_config_path}|" "$HYPRPAPER_FILE"

  apply_wallpaper_runtime "$_wall"
}

# Sincroniza o tema do argvus-taskbar-storage com o tema ativo.
# Mapeia: dark -> argvus-dark-aether.css, silver -> argvus-dark-silver.css, slate -> argvus-dark-slate.css, light -> argvus-light-veil.css
apply_argvus_storage_theme() {
  _storage_theme_dir="$(paths_config taskbar-storage/config/themes)"
  _storage_theme_dest="$(paths_config taskbar-storage/config/theme.css)"

  # Tenta encontrar os arquivos de tema em ordem de prioridade:
  # 1. Diretório do usuário (~/.config/argvus/taskbar/storage/themes)
  # 2. Diretório canônico do sistema (/usr/share/argvus/taskbar-storage/config/themes)
  # 3. Diretório legado do sistema (/etc/argvus/taskbar/storage/themes)
  _theme_src=""
  case "$THEME" in
    argvus-dark-aether|argvus-dark-aether-float)
      _theme_name="argvus-dark-aether.css" ;;
    argvus-dark-silver|argvus-dark-silver-float)
    _theme_name="argvus-dark-silver.css" ;;
    argvus-dark-slate|argvus-dark-slate-float)
      _theme_name="argvus-dark-slate.css" ;;
    argvus-light-veil|argvus-light-veil-float)
      _theme_name="argvus-light-veil.css" ;;
    argvus-dark-universe|argvus-dark-universe-float)
      _theme_name="argvus-dark-universe.css" ;;
    *)
      return 0 ;;
  esac

  # Tenta o diretório do usuário
  if [ -f "${_storage_theme_dir}/${_theme_name}" ]; then
    _theme_src="${_storage_theme_dir}/${_theme_name}"
  # Tenta o sistema canônico
  elif [ -f "$(paths_system_config taskbar-storage/config/themes/${_theme_name})" ]; then
    _theme_src="$(paths_system_config taskbar-storage/config/themes/${_theme_name})"
  # Mantém instalações antigas funcionais durante a migração.
  elif [ -f "/etc/argvus/taskbar/storage/themes/${_theme_name}" ]; then
    _theme_src="/etc/argvus/taskbar/storage/themes/${_theme_name}"
  # Tenta o diretório do projeto argvus-taskbar-storage (desenvolvimento).
  elif [ -n "$_workspace_root" ] && [ -f "$_workspace_root/argvus-taskbar-storage/src/usr/share/argvus/taskbar-storage/config/themes/${_theme_name}" ]; then
    _theme_src="$_workspace_root/argvus-taskbar-storage/src/usr/share/argvus/taskbar-storage/config/themes/${_theme_name}"
  else
    return 0
  fi

  mkdir -p "$(dirname "$_storage_theme_dest")"
  cp "$_theme_src" "$_storage_theme_dest"
}

# Sincroniza o tema do argvus-taskbar-calendar com o tema ativo.
# O destino fica no cache do usuário para a troca de tema não precisar de sudo.
apply_argvus_calendar_theme() {
  _calendar_theme_cache="${XDG_CACHE_HOME:-$HOME/.cache}/argvus-taskbar-calendar/theme.css"
  _calendar_theme_name=""

  case "$THEME" in
    argvus-dark-aether|argvus-dark-aether-float|argvus-dark-silver|argvus-dark-silver-float|argvus-dark-slate|argvus-dark-slate-float)
      _calendar_theme_name="${THEME}.css" ;;
    argvus-dark-universe|argvus-dark-universe-float)
      _calendar_theme_name="${THEME}.css" ;;
    argvus-light-veil|argvus-light-veil-float)
      _calendar_theme_name="${THEME}.css" ;;
    *)
      return 0 ;;
  esac

  _calendar_theme_src=""
  if [ -f "$(paths_config "argvus-taskbar-calendar/themes/${_calendar_theme_name}")" ]; then
    _calendar_theme_src="$(paths_config "argvus-taskbar-calendar/themes/${_calendar_theme_name}")"
  elif [ -f "/etc/argvus/taskbar/calendar/themes/${_calendar_theme_name}" ]; then
    _calendar_theme_src="/etc/argvus/taskbar/calendar/themes/${_calendar_theme_name}"
  elif [ -n "$_workspace_root" ] && [ -f "$_workspace_root/argvus-taskbar-calendar/resources/themes/${_calendar_theme_name}" ]; then
    _calendar_theme_src="$_workspace_root/argvus-taskbar-calendar/resources/themes/${_calendar_theme_name}"
  else
    return 0
  fi

  mkdir -p "$(dirname "$_calendar_theme_cache")"
  cp "$_calendar_theme_src" "$_calendar_theme_cache"
  command -v argvus-taskbar-calendar >/dev/null 2>&1 && argvus-taskbar-calendar reload >/dev/null 2>&1 || true
}

if [ -z "$THEME" ]; then
  printf 'Usage: theme-switch <theme-name>\n' >&2
  exit 1
fi

if [ ! -f "$SUPERFILE_THEMES/$THEME.toml" ]; then
  printf 'Warning: superfile theme not found: %s\n' "$SUPERFILE_THEMES/$THEME.toml" >&2
fi

if [ ! -f "$QT6CT_COLORS/$THEME.conf" ]; then
  printf 'Warning: qt6ct color scheme not found: %s\n' "$QT6CT_COLORS/$THEME.conf" >&2
fi

if ! _theme_wallpaper="$(find_theme_wallpaper "$THEME")"; then
  if [ "$RUNTIME" -eq 1 ]; then
    exit 1
  fi
  _theme_wallpaper=""
fi

theme_transition_begin

printf '%s' "$THEME" > "$ACTIVE_FILE"

# ----- Per-theme waybar layout -----
# Refresh the canonical mutable copies. The previous legacy `waybar/...`
# arguments resolved against /usr/share/argvus/waybar, which no longer exists
# after the project split and left stale script paths in user configurations.
refresh_managed_waybar_file taskbar/config/argvus-taskbar.jsonc
refresh_managed_waybar_file taskbar/config/argvus-taskbar.css
refresh_managed_waybar_file widget-telemetry/config/argvus-widget-telemetry.jsonc
refresh_managed_waybar_file widget-telemetry/config/argvus-widget-telemetry.css
_waybar_cfg="$(paths_config taskbar/config/argvus-taskbar.jsonc)"
_waybar_cfg_widget_telemetry="$(paths_config widget-telemetry/config/argvus-widget-telemetry.jsonc)"
_widget_telemetry_css="$(paths_config widget-telemetry/config/argvus-widget-telemetry.css)"

# System CSS uses the appearance package's shared mode file. Mutable user
# copies keep the relative import because theme/mode switching writes the
# per-user Waybar file beside these styles.
for _waybar_style in "$(paths_config taskbar/config/argvus-taskbar.css)" \
                     "$_widget_telemetry_css"; do
  [ -f "$_waybar_style" ] || continue
  sed -i 's|@import url("/usr/share/argvus/appearance/config/waybar/mode.css");|@import url("./mode.css");|' "$_waybar_style"
done

case "$THEME" in
  argvus-dark-aether | argvus-dark-silver | argvus-light-veil | argvus-dark-slate | argvus-dark-universe)
    sed -i "s|\"margin-top\": [0-9]*|\"margin-top\": 0|" "$_waybar_cfg"
    sed -i "s|\"margin-left\": [0-9]*|\"margin-left\": 0|" "$_waybar_cfg"
    sed -i "s|\"margin-right\": [0-9]*|\"margin-right\": 0|" "$_waybar_cfg"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": 0|" "$_waybar_cfg"
    sed -i "s|\"margin-top\": -\?[0-9]*|\"margin-top\": 0|" "$_waybar_cfg_widget_telemetry"
    sed -i "s|\"margin-left\": -\?[0-9]*|\"margin-left\": 0|" "$_waybar_cfg_widget_telemetry"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": 0|" "$_waybar_cfg_widget_telemetry"
    sed -i '/^window#waybar {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    sed -i '/^#workspaces button/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    sed -i '/^#workspaces button\.active,/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    sed -i '/^tooltip {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    sed -i '/^#right-0, #right-1, #right-2, #right-search, #mpris/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    sed -i '/^window#waybar {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$_widget_telemetry_css"
    _rofi_cfg="$(paths_config launcher/config/theme.rasi)"
    sed -i '/^window {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$_rofi_cfg"
    sed -i '/^element selected.normal {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$_rofi_cfg"
    ;;
  *)
    sed -i "s|\"margin-top\": [0-9]*|\"margin-top\": 5|" "$_waybar_cfg"
    sed -i "s|\"margin-left\": [0-9]*|\"margin-left\": 20|" "$_waybar_cfg"
    sed -i "s|\"margin-right\": [0-9]*|\"margin-right\": 20|" "$_waybar_cfg"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": -8|" "$_waybar_cfg"
    sed -i "s|\"margin-top\": -\?[0-9]*|\"margin-top\": 15|" "$_waybar_cfg_widget_telemetry"
    sed -i "s|\"margin-left\": -\?[0-9]*|\"margin-left\": 20|" "$_waybar_cfg_widget_telemetry"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": 15|" "$_waybar_cfg_widget_telemetry"
    sed -i '/^window#waybar {/,/^}/s/border-radius: [0-9]*px;/border-radius: 4px;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    sed -i '/^#workspaces button/,/^}/s/border-radius: [0-9]*px;/border-radius: 5px;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    sed -i '/^#workspaces button\.active,/,/^}/s/border-radius: [0-9]*px;/border-radius: 4px;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    sed -i '/^tooltip {/,/^}/s/border-radius: [0-9]*px;/border-radius: 8px;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    sed -i '/^#right-0, #right-1, #right-2, #right-search, #mpris/,/^}/s/border-radius: [0-9]*px;/border-radius: 5px;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    sed -i '/^window#waybar {/,/^}/s/border-radius: [0-9]*px;/border-radius: 8px;/' "$_widget_telemetry_css"
    _rofi_cfg="$(paths_config launcher/config/theme.rasi)"
    sed -i '/^window {/,/^}/s/border-radius: [0-9]*px;/border-radius: 6px;/' "$_rofi_cfg"
    sed -i '/^element selected.normal {/,/^}/s/border-radius: [0-9]*px;/border-radius: 5px;/' "$_rofi_cfg"
    ;;
esac

case "$THEME" in
  argvus-dark-slate)
    sed -i '/^window#waybar {/,/^}/s/border: .*;/border: none;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    ;;
  *)
    sed -i '/^window#waybar {/,/^}/s/border: .*;/border: 1px solid @th-decorate;/' "$(paths_config taskbar/config/argvus-taskbar.css)"
    ;;
esac

sed -i "s|@import url(\"./themes/.*/theme.css\");|@import url(\"./themes/${THEME}/theme.css\");|" \
  "$(paths_config taskbar/config/argvus-taskbar.css)"

sed -i "s|@import url(\"./themes/.*/widget-telemetry-theme.css\");|@import url(\"./themes/${THEME}/widget-telemetry-theme.css\");|" \
  "$(paths_config widget-telemetry/config/argvus-widget-telemetry.css)"

write_managed_css_block "$(paths_config taskbar/config/argvus-taskbar.css)" "* {
  font-family: \"${ARGVUS_TASKBAR_FAMILY}\", \"Symbols Nerd Font Mono\", monospace;
  font-size: ${ARGVUS_TASKBAR_SIZE}px;
}

#custom-icon-window,
#network,
#bluetooth,
#custom-bluetooth,
#custom-expand-icon,
#custom-storage,
#custom-recording,
#custom-search,
#pulseaudio,
#power-profiles-daemon,
#custom-settings,
#custom-power {
  font-family: \"Symbols Nerd Font Mono\";
}"

write_managed_css_block "$(paths_config widget-telemetry/config/argvus-widget-telemetry.css)" "* {
  font-family: \"${ARGVUS_SYSINFO_FAMILY}\", \"Symbols Nerd Font Mono\", monospace;
  font-size: ${ARGVUS_SYSINFO_SIZE}px;
}"

sed -i "s|rofi -config [^ ]* -show drun|rofi -config ${ROFI_CONFIG} -show drun|" \
  "$_waybar_cfg"

sed -i "s|^@theme \".*theme.rasi\"$|@theme \"${ROFI_THEME}\"|" "$ROFI_CONFIG"
sed -i "s|font: \".*\";|font: \"${ARGVUS_APPS_FONT}\";|" "$ROFI_CONFIG"

sed -i "s|^@import \".*themes/.*/theme.rasi\"$|@import \"${ROFI_THEMES}/${THEME}/theme.rasi\"|" \
  "$ROFI_THEME"

sed -i "s|^@import \".*mode.rasi\"$|@import \"${ROFI_MODE}\"|" "$ROFI_THEME"

command -v argvus-terminal >/dev/null 2>&1 && argvus-terminal --apply "$THEME" >/dev/null 2>&1 || true

if [ -f "$FOOT_SYSTEM_THEMES/$THEME/theme.ini" ]; then
  mkdir -p "$FOOT_THEMES/$THEME"
  cp "$FOOT_SYSTEM_THEMES/$THEME/theme.ini" "$FOOT_THEMES/$THEME/theme.ini"
fi

if [ -f "$FOOT_THEMES/$THEME/theme.ini" ]; then
  sed -i "s|^include = .*/foot/themes/.*/theme.ini|include = ${FOOT_THEMES}/${THEME}/theme.ini|" "$FOOT_CONFIG"
  sed -i "s|^font=.*|font=${ARGVUS_TERMINAL_FAMILY}:size=${ARGVUS_TERMINAL_SIZE}, Noto Color Emoji:size=12|" "$FOOT_CONFIG"
  _native_foot="${ARGVUS_CONFIG_HOME}/foot/foot.ini"
  if should_manage_foot_config "$_native_foot"; then
    mkdir -p "${_native_foot%/*}"
    if [ ! -f "$_native_foot" ]; then
      cp "$FOOT_CONFIG" "$_native_foot"
    fi
    sed -i "s|^include = .*/foot/themes/.*/theme.ini|include = ${FOOT_THEMES}/${THEME}/theme.ini|" "$_native_foot"
    sed -i "s|^font=.*|font=${ARGVUS_TERMINAL_FAMILY}:size=${ARGVUS_TERMINAL_SIZE}, Noto Color Emoji:size=12|" "$_native_foot"
  fi
  apply_running_foot_theme "$FOOT_THEMES/$THEME/theme.ini"
fi

apply_dunst_theme

if [ -f "$HYPR_THEMES/$THEME/hyprtoolkit.conf" ]; then
  cp "$HYPR_THEMES/$THEME/hyprtoolkit.conf" "$(paths_config appearance/config/hypr/hyprtoolkit.conf)"
  replace_or_append_setting "$(paths_config appearance/config/hypr/hyprtoolkit.conf)" font_family "\"$ARGVUS_SYSTEM_FAMILY\""
  replace_or_append_setting "$(paths_config appearance/config/hypr/hyprtoolkit.conf)" font_size "$ARGVUS_SYSTEM_SIZE"
fi

if [ -f "$HYPR_THEMES/$THEME/application-style.conf" ]; then
  cp "$HYPR_THEMES/$THEME/application-style.conf" "$(paths_config appearance/config/hypr/application-style.conf)"
fi

_qt6ct_conf="$(paths_config appearance/config/qt6ct/qt6ct.conf)"
if [ -f "$_qt6ct_conf" ] && [ -f "$QT6CT_COLORS/$THEME.conf" ]; then
  sed -i "s|^color_scheme_path=.*|color_scheme_path=${QT6CT_COLORS}/${THEME}.conf|" "$_qt6ct_conf"
  sed -i "s|^custom_palette=.*|custom_palette=true|" "$_qt6ct_conf"
fi

if [ "$RUNTIME" -eq 1 ] && { [ -f "$HYPR_THEMES/$THEME/hyprtoolkit.conf" ] || [ -f "$HYPR_THEMES/$THEME/application-style.conf" ]; }; then
  systemctl --user set-environment QT_QPA_PLATFORM=wayland QT_QPA_PLATFORMTHEME=qt6ct QT_QUICK_CONTROLS_STYLE=org.hyprland.style
  systemctl --user restart hyprpolkitagent 2>/dev/null || true
fi

command -v argvus-system-monitor >/dev/null 2>&1 && argvus-system-monitor --apply "$THEME" >/dev/null 2>&1 || true

if [ -f "$SNAPPY_THEMES/$THEME/theme.ini" ]; then
  _snappy_conf="$(paths_config app-profiles/config/snappy-switcher/config.ini)"
  sed -i "s|^name = .*|name = ${THEME}/theme.ini|" "$_snappy_conf"
fi

if [ -d "$YAZI_SYSTEM_ROOT/flavors/$THEME.yazi" ]; then
  mkdir -p "$YAZI_CONFIG_ROOT/flavors/$THEME.yazi"
  cp -R "$YAZI_SYSTEM_ROOT/flavors/$THEME.yazi/." "$YAZI_CONFIG_ROOT/flavors/$THEME.yazi/"
fi

if [ -f "$YAZI_CONFIG_ROOT/flavors/$THEME.yazi/flavor.toml" ]; then
  printf '[flavor]\ndark = "%s"\n' "$THEME" > "$YAZI_CONFIG_ROOT/theme.toml"
else
  printf 'Warning: yazi flavor not found: %s\n' "$YAZI_CONFIG_ROOT/flavors/$THEME.yazi/flavor.toml" >&2
fi

_superfile_conf="$SUPERFILE_CONFIG_ROOT/config.toml"
if [ -f "$_superfile_conf" ] && [ -f "$SUPERFILE_THEMES/$THEME.toml" ]; then
  replace_or_append_setting "$_superfile_conf" theme "\"${THEME}\""
  _native_superfile="${ARGVUS_CONFIG_HOME}/superfile"
  if [ -d "$_native_superfile" ]; then
    mkdir -p "$_native_superfile/theme"
    cp "$SUPERFILE_THEMES/$THEME.toml" "$_native_superfile/theme/$THEME.toml"
    if [ ! -f "$_native_superfile/config.toml" ]; then
      cp "$_superfile_conf" "$_native_superfile/config.toml"
    fi
    replace_or_append_setting "$_native_superfile/config.toml" theme "\"${THEME}\""
  fi
fi

# Reset GTK mode to match the selected theme.
MODE_CSS="$(paths_config appearance/config/waybar/mode.css)"
printf '/* mode.css — reset on theme switch */\n' > "$MODE_CSS"
GTK_MODE_FILE="${ARGVUS_CONFIG_HOME}/argvus/.gtk-mode"
mkdir -p "$(dirname "$GTK_MODE_FILE")"
case "$THEME" in
  argvus-light-veil | argvus-light-veil-float)
    _gtk_theme_name="$(gtk_theme_name_for_theme "$THEME")"
    apply_gtk_theme_files light "$_gtk_theme_name" 0
    apply_gtk_runtime_settings prefer-light "$_gtk_theme_name" Adwaita-dark
    ;;
  *)
    _gtk_theme_name="$(gtk_theme_name_for_theme "$THEME")"
    apply_gtk_theme_files dark "$_gtk_theme_name" 1
    apply_gtk_runtime_settings prefer-dark "$_gtk_theme_name" Adwaita
    ;;
esac

# Every theme owns its default accent. A manual accent remains active only until
# the user switches themes, including when switching back to the same theme.
if ! sh "$(paths_config appearance/sh/accent-switch.sh)" --theme-default; then
  printf 'Error: could not restore the default accent for %s.\n' "$THEME" >&2
  exit 1
fi

_hyprlock_theme_script="$(paths_config lock/sh/hyprlock-theme.sh)"
if [ -f "$_hyprlock_theme_script" ]; then
  if ! sh "$_hyprlock_theme_script" --invalidate; then
    printf 'Error: could not apply the Hyprlock theme for %s.\n' "$THEME" >&2
    exit 1
  fi
fi

# Re-apply the user's spaces override after the theme has rewritten its
# generated Waybar files. Spacing is a user preference for every theme type.
_spaces_script="$(paths_config hyprland/sh/spaces-switch.sh)"
if [ -f "$_spaces_script" ]; then
  if ! sh "$_spaces_script" --apply-static; then
    printf 'Error: could not re-apply the spaces override for %s.\n' "$THEME" >&2
    exit 1
  fi
fi

# Set wallpaper for the new theme
if ! apply_wallpaper "$_theme_wallpaper"; then
  printf 'Error: could not prepare the wallpaper for %s.\n' "$THEME" >&2
  exit 1
fi

if [ "$RUNTIME" -eq 1 ]; then
  # Signal running kitty instances to reload config (SIGUSR1)
  for _pid in $(pgrep -x kitty 2>/dev/null); do
    kill -USR1 "$_pid" 2>/dev/null || true
  done

  # Signal running foot instances to use their dark color theme.
  for _pid in $(pgrep -x foot 2>/dev/null) $(pgrep -x footclient 2>/dev/null); do
    kill -USR1 "$_pid" 2>/dev/null || true
  done
fi

apply_argvus_storage_theme
apply_argvus_calendar_theme

THEME_CONFIG_READY=1
if [ "$RUNTIME" -eq 1 ]; then
  theme_transition_cleanup 0
fi
printf "Theme '%s' applied.\n" "$THEME"
