#!/usr/bin/env sh
# theme-switch - apply a named theme across the whole argvus desktop
# Usage: theme-switch <theme-name>
# shellcheck disable=SC1090,SC1091,SC2034

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/scripts/argvus/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"
ARGVUS_MUTABLE_CONFIG=1

THEME="${1:-}"
ACTIVE_FILE="${ARGVUS_CONFIG_HOME}/argvus/.active-theme"
RUNTIME=1
mkdir -p "${ACTIVE_FILE%/*}"

if [ "${ARGVUS_NO_RUNTIME:-0}" = 1 ]; then
  RUNTIME=0
fi

if [ -z "$THEME" ]; then
  THEME=$(
    rofi -config "$(paths_config rofi/config.rasi)" -dmenu -p "   Select Theme" -i -theme-str 'listview {lines: 10;}' <<'EOF'
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

ensure_theme_parent() {
  _relative="$1"
  _theme="$2"
  _target="$(paths_user_config "${_relative}/${_theme}")"

  if [ -d "$_target" ]; then
    dirname "$_target"
    return 0
  fi

  for _source in \
    "$(paths_override_config "${_relative}/${_theme}")" \
    "$(paths_generated_config "${_relative}/${_theme}")" \
    "$(paths_system_config "${_relative}/${_theme}")"; do
    [ "$_source" = "$_target" ] && continue
    if [ -d "$_source" ]; then
      mkdir -p "$_target"
      cp -R "$_source/." "$_target/"
      dirname "$_target"
      return 0
    fi
  done

  return 1
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
  _start="/* argvus-settings-fonts:start */"
  _end="/* argvus-settings-fonts:end */"
  [ -f "$_file" ] || return 0

  if grep -qF "$_start" "$_file"; then
    awk -v start="$_start" -v end="$_end" -v block="$_block" '
      $0 == start { print start; print block; skip = 1; next }
      $0 == end { print end; skip = 0; next }
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

ARGVUS_APPS_NAME="$(font_state_value apps_name "$(font_state_value default_name "Terminus (TTF) Bold")")"
ARGVUS_APPS_SIZE="$(font_state_value apps_size "$(font_state_value default_size 13)")"
ARGVUS_APPS_FONT="${ARGVUS_APPS_NAME} ${ARGVUS_APPS_SIZE}"
ARGVUS_TASKBAR_FAMILY="$(font_state_value taskbar_family "$(font_state_value default_family "Terminus (TTF)")")"
ARGVUS_TASKBAR_SIZE="$(font_state_value taskbar_size "$(font_state_value default_size 14)")"
ARGVUS_SYSINFO_FAMILY="$(font_state_value sysinfo_family "$(font_state_value monospace_family "Terminus (TTF)")")"
ARGVUS_SYSINFO_SIZE="$(font_state_value sysinfo_size "$(font_state_value monospace_size 15)")"
ARGVUS_SYSTEM_FAMILY="$(font_state_value system_family "$(font_state_value default_family "Terminus (TTF)")")"
ARGVUS_SYSTEM_SIZE="$(font_state_value system_size "$(font_state_value default_size 13)")"
ARGVUS_TERMINAL_FAMILY="$(font_state_value terminal_family "$(font_state_value monospace_family "JetBrainsMono Nerd Font")")"
ARGVUS_TERMINAL_SIZE="$(font_state_value terminal_size "$(font_state_value monospace_size 13)")"

native_config_home() {
  printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}"
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
    _theme_dir="$(optional_theme_parent "${_gtk_version}/themes" "$THEME")"

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

HYPR_THEMES="$(required_theme_parent hypr/themes "$THEME")"
WAYBAR_THEMES="$(optional_theme_parent waybar/themes "$THEME")"
QS_THEMES="$(optional_theme_parent quickshell/argvus-control-panel/themes "$THEME")"
ROFI_THEMES="$(optional_theme_parent rofi/themes "$THEME")"
ROFI_CONFIG="$(paths_config rofi/config.rasi)"
ROFI_THEME="$(paths_config rofi/theme.rasi)"
ROFI_MODE="$(paths_config rofi/mode.rasi)"
DUNST_THEMES="$(optional_theme_parent dunst/themes "$THEME")"
FOOT_CONFIG="$(paths_config foot/foot.ini)"
FOOT_THEMES="$(optional_theme_parent foot/themes "$THEME")"
FOOT_SYSTEM_THEMES="$(paths_system_config foot/themes)"
BOTTOM_THEMES="$(optional_theme_parent bottom/themes "$THEME")"
YAZI_CONFIG_ROOT="$(paths_config yazi)"
YAZI_SYSTEM_ROOT="$(paths_system_config yazi)"
SNAPPY_THEMES="$(optional_theme_parent snappy-switcher/themes "$THEME")"
SUPERFILE_CONFIG_ROOT="$(paths_config superfile)"
SUPERFILE_THEMES="$(optional_theme_file_parent superfile/theme "${THEME}.toml")"
QT6CT_COLORS="$(paths_config qt6ct/colors)"
HYPRPAPER_FILE="$(paths_config hypr/hyprpaper.conf)"
HYPRPAPER_DIR="$(paths_backgrounds argvus)"

apply_wallpaper_runtime() {
  _wall="$1"
  [ "$RUNTIME" -eq 1 ] || return 0
  hypr_apply_wallpaper "$_wall"
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

toml_color_value() {
  _file="$1"
  _key="$2"
  sed -n "s|^[[:space:]]*${_key}[[:space:]]*=[[:space:]]*\"\\([^\"]*\\)\".*|\\1|p" "$_file" | head -n1
}

replace_style_color() {
  _file="$1"
  _key="$2"
  _value="$3"
  [ -f "$_file" ] || return 0
  if sed -n "/^[[:space:]]*${_key}[[:space:]]*=/p" "$_file" | grep -q 'bold[[:space:]]*=[[:space:]]*true'; then
    sed -i "s|^[[:space:]]*${_key}[[:space:]]*=.*|${_key} = {color = \"${_value}\", bold = true}|" "$_file"
  else
    sed -i "s|^[[:space:]]*${_key}[[:space:]]*=.*|${_key} = {color = \"${_value}\"}|" "$_file"
  fi
}

replace_plain_color() {
  _file="$1"
  _key="$2"
  _value="$3"
  [ -f "$_file" ] || return 0
  sed -i "s|^[[:space:]]*${_key}[[:space:]]*=.*|${_key} = \"${_value}\"|" "$_file"
}

apply_bottom_theme_to_profile() {
  _profile="$1"
  _theme_file="$2"
  [ -f "$_profile" ] && [ -f "$_theme_file" ] || return 0

  _accent="$(toml_color_value "$_theme_file" border)"
  _fg="$(toml_color_value "$_theme_file" foreground)"
  _bg="$(toml_color_value "$_theme_file" background)"
  _selected_bg="$(toml_color_value "$_theme_file" selected_bg)"
  _selected_fg="$(toml_color_value "$_theme_file" selected_text)"
  _mem="$(toml_color_value "$_theme_file" mem_color)"
  _swap="$(toml_color_value "$_theme_file" swap_color)"
  _rx="$(toml_color_value "$_theme_file" rx_color)"
  _tx="$(toml_color_value "$_theme_file" tx_color)"

  [ -n "$_accent" ] || return 0
  [ -n "$_fg" ] || _fg="$_accent"
  [ -n "$_bg" ] || _bg="#111316"
  [ -n "$_selected_bg" ] || _selected_bg="$_accent"
  [ -n "$_selected_fg" ] || _selected_fg="$_bg"
  [ -n "$_mem" ] || _mem="$_accent"
  [ -n "$_swap" ] || _swap="$_mem"
  [ -n "$_rx" ] || _rx="$_fg"
  [ -n "$_tx" ] || _tx="$_accent"

  replace_plain_color "$_profile" all_entry_color "$_accent"
  replace_plain_color "$_profile" avg_entry_color "$_fg"
  sed -i "s|^[[:space:]]*cpu_core_colors[[:space:]]*=.*|cpu_core_colors = [\"${_accent}\", \"${_mem}\", \"${_swap}\", \"${_fg}\", \"${_rx}\", \"${_accent}\", \"${_mem}\", \"${_swap}\"]|" "$_profile"
  replace_plain_color "$_profile" ram_color "$_accent"
  replace_plain_color "$_profile" swap_color "$_swap"
  replace_plain_color "$_profile" rx_color "$_rx"
  replace_plain_color "$_profile" tx_color "$_tx"
  replace_style_color "$_profile" headers "$_accent"
  replace_plain_color "$_profile" graph_color "$_fg"
  replace_style_color "$_profile" legend_text "$_fg"
  replace_plain_color "$_profile" border_color "$_swap"
  replace_plain_color "$_profile" selected_border_color "$_accent"
  replace_style_color "$_profile" widget_title "$_accent"
  replace_style_color "$_profile" text "$_fg"
  sed -i "s|^[[:space:]]*selected_text[[:space:]]*=.*|selected_text = {color = \"${_selected_fg}\", bg_color = \"${_selected_bg}\"}|" "$_profile"
  replace_style_color "$_profile" disabled_text "$_swap"
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
  _dunstrc="$(paths_config dunst/dunstrc)"
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

# Sincroniza o tema do argvus-storage com o tema ativo.
# Mapeia: dark -> argvus-dark-aether.css, silver -> argvus-dark-silver.css, slate -> argvus-dark-slate.css, light -> argvus-light-veil.css
apply_argvus_storage_theme() {
  _storage_theme_dir="$(paths_config argvus-storage/themes)"
  _storage_theme_dest="$(paths_config argvus-storage/theme.css)"

  # Tenta encontrar os arquivos de tema em ordem de prioridade:
  # 1. Diretório do usuário (~/.config/argvus-storage/themes)
  # 2. Diretório do sistema (/etc/argvus-storage/themes)
  # 3. Diretório do projeto (para desenvolvimento)
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
  # Tenta o sistema
  elif [ -f "/etc/argvus-storage/themes/${_theme_name}" ]; then
    _theme_src="/etc/argvus-storage/themes/${_theme_name}"
  # Tenta o diretório do projeto argvus-storage (desenvolvimento)
  elif [ -f "$(dirname "$0")/../../../../argvus-storage/themes/${_theme_name}" ]; then
    _theme_src="$(dirname "$0")/../../../../argvus-storage/themes/${_theme_name}"
  # Tenta o diretório legado, caso exista em uma instalação antiga.
  elif [ -f "$(paths_config argvus-storage/themes/${_theme_name})" ]; then
    _theme_src="$(paths_config argvus-storage/themes/${_theme_name})"
  else
    return 0
  fi

  mkdir -p "$(dirname "$_storage_theme_dest")"
  cp "$_theme_src" "$_storage_theme_dest"
}

# Sincroniza o tema do argvus-calendar com o tema ativo.
# O destino fica no cache do usuário para a troca de tema não precisar de sudo.
apply_argvus_calendar_theme() {
  _calendar_theme_cache="${XDG_CACHE_HOME:-$HOME/.cache}/argvus-calendar/theme.css"
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
  if [ -f "$(paths_config "argvus-calendar/themes/${_calendar_theme_name}")" ]; then
    _calendar_theme_src="$(paths_config "argvus-calendar/themes/${_calendar_theme_name}")"
  elif [ -f "/etc/argvus-calendar/themes/${_calendar_theme_name}" ]; then
    _calendar_theme_src="/etc/argvus-calendar/themes/${_calendar_theme_name}"
  elif [ -f "$(dirname "$0")/../../../../argvus-calendar/resources/themes/${_calendar_theme_name}" ]; then
    _calendar_theme_src="$(dirname "$0")/../../../../argvus-calendar/resources/themes/${_calendar_theme_name}"
  else
    return 0
  fi

  mkdir -p "$(dirname "$_calendar_theme_cache")"
  cp "$_calendar_theme_src" "$_calendar_theme_cache"
  command -v argvus-calendar >/dev/null 2>&1 && argvus-calendar reload >/dev/null 2>&1 || true
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

printf '%s' "$THEME" > "$ACTIVE_FILE"

# ----- Per-theme waybar layout -----
_waybar_cfg="$(paths_config waybar/argvus-taskbar.jsonc)"
_waybar_cfg_sysinfo="$(paths_config waybar/argvus-sysinfo.jsonc)"
_sysinfo_css="$(paths_config waybar/argvus-sysinfo.css)"

case "$THEME" in
  argvus-dark-aether | argvus-dark-silver | argvus-light-veil | argvus-dark-slate | argvus-dark-universe)
    sed -i "s|\"margin-top\": [0-9]*|\"margin-top\": 0|" "$_waybar_cfg"
    sed -i "s|\"margin-left\": [0-9]*|\"margin-left\": 0|" "$_waybar_cfg"
    sed -i "s|\"margin-right\": [0-9]*|\"margin-right\": 0|" "$_waybar_cfg"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": 3|" "$_waybar_cfg"
    sed -i "s|\"margin-top\": -\?[0-9]*|\"margin-top\": 1|" "$_waybar_cfg_sysinfo"
    sed -i "s|\"margin-left\": -\?[0-9]*|\"margin-left\": 1|" "$_waybar_cfg_sysinfo"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": 1|" "$_waybar_cfg_sysinfo"
    sed -i '/^window#waybar {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$(paths_config waybar/argvus-taskbar.css)"
    sed -i '/^#workspaces button/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$(paths_config waybar/argvus-taskbar.css)"
    sed -i '/^#workspaces button\.active,/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$(paths_config waybar/argvus-taskbar.css)"
    sed -i '/^tooltip {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$(paths_config waybar/argvus-taskbar.css)"
    sed -i '/#right-0, #right-1, #right-2, #right-search, #mpris {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$(paths_config waybar/argvus-taskbar.css)"
    sed -i '/^window#waybar {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$_sysinfo_css"
    _rofi_cfg="$(paths_config rofi/theme.rasi)"
    sed -i '/^window {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$_rofi_cfg"
    sed -i '/^element selected.normal {/,/^}/s/border-radius: [0-9]*px;/border-radius: 0px;/' "$_rofi_cfg"
    ;;
  *)
    sed -i "s|\"margin-top\": [0-9]*|\"margin-top\": 5|" "$_waybar_cfg"
    sed -i "s|\"margin-left\": [0-9]*|\"margin-left\": 20|" "$_waybar_cfg"
    sed -i "s|\"margin-right\": [0-9]*|\"margin-right\": 20|" "$_waybar_cfg"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": -8|" "$_waybar_cfg"
    sed -i "s|\"margin-top\": -\?[0-9]*|\"margin-top\": 15|" "$_waybar_cfg_sysinfo"
    sed -i "s|\"margin-left\": -\?[0-9]*|\"margin-left\": 20|" "$_waybar_cfg_sysinfo"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": 15|" "$_waybar_cfg_sysinfo"
    sed -i '/^window#waybar {/,/^}/s/border-radius: [0-9]*px;/border-radius: 4px;/' "$(paths_config waybar/argvus-taskbar.css)"
    sed -i '/^#workspaces button/,/^}/s/border-radius: [0-9]*px;/border-radius: 5px;/' "$(paths_config waybar/argvus-taskbar.css)"
    sed -i '/^#workspaces button\.active,/,/^}/s/border-radius: [0-9]*px;/border-radius: 4px;/' "$(paths_config waybar/argvus-taskbar.css)"
    sed -i '/^tooltip {/,/^}/s/border-radius: [0-9]*px;/border-radius: 8px;/' "$(paths_config waybar/argvus-taskbar.css)"
    sed -i '/#right-0, #right-1, #right-2, #right-search, #mpris {/,/^}/s/border-radius: [0-9]*px;/border-radius: 5px;/' "$(paths_config waybar/argvus-taskbar.css)"
    sed -i '/^window#waybar {/,/^}/s/border-radius: [0-9]*px;/border-radius: 8px;/' "$_sysinfo_css"
    _rofi_cfg="$(paths_config rofi/theme.rasi)"
    sed -i '/^window {/,/^}/s/border-radius: [0-9]*px;/border-radius: 6px;/' "$_rofi_cfg"
    sed -i '/^element selected.normal {/,/^}/s/border-radius: [0-9]*px;/border-radius: 5px;/' "$_rofi_cfg"
    ;;
esac

case "$THEME" in
  argvus-dark-slate)
    sed -i '/^window#waybar {/,/^}/s/border: .*;/border: none;/' "$(paths_config waybar/argvus-taskbar.css)"
    ;;
  *)
    sed -i '/^window#waybar {/,/^}/s/border: .*;/border: 1px solid @th-decorate;/' "$(paths_config waybar/argvus-taskbar.css)"
    ;;
esac

sed -i "s|@import url(\"./themes/.*/theme.css\");|@import url(\"./themes/${THEME}/theme.css\");|" \
  "$(paths_config waybar/argvus-taskbar.css)"

sed -i "s|@import url(\"./themes/.*/sysinfo-theme.css\");|@import url(\"./themes/${THEME}/sysinfo-theme.css\");|" \
  "$(paths_config waybar/argvus-sysinfo.css)"

write_managed_css_block "$(paths_config waybar/argvus-taskbar.css)" "* {
  font-family: \"${ARGVUS_TASKBAR_FAMILY}\", \"Font Awesome 7 Free\", monospace;
  font-size: ${ARGVUS_TASKBAR_SIZE}px;
}"

write_managed_css_block "$(paths_config waybar/argvus-sysinfo.css)" "* {
  font-family: \"${ARGVUS_SYSINFO_FAMILY}\", \"Symbols Nerd Font Mono\", monospace;
  font-size: ${ARGVUS_SYSINFO_SIZE}px;
}"

sed -i "s|rofi -config [^ ]* -show drun|rofi -config ${ROFI_CONFIG} -show drun|" \
  "$_waybar_cfg"

sed -i "s|@theme \".*/rofi/theme.rasi\"|@theme \"${ROFI_THEME}\"|" "$ROFI_CONFIG"
sed -i "s|font: \".*\";|font: \"${ARGVUS_APPS_FONT}\";|" "$ROFI_CONFIG"

sed -i "s|@import \".*/rofi/themes/.*/theme.rasi\"|@import \"${ROFI_THEMES}/${THEME}/theme.rasi\"|" \
  "$ROFI_THEME"

sed -i "s|@import \".*/rofi/mode.rasi\"|@import \"${ROFI_MODE}\"|" "$ROFI_THEME"

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
  cp "$HYPR_THEMES/$THEME/hyprtoolkit.conf" "$(paths_config hypr/hyprtoolkit.conf)"
  replace_or_append_setting "$(paths_config hypr/hyprtoolkit.conf)" font_family "\"$ARGVUS_SYSTEM_FAMILY\""
  replace_or_append_setting "$(paths_config hypr/hyprtoolkit.conf)" font_size "$ARGVUS_SYSTEM_SIZE"
fi

if [ -f "$HYPR_THEMES/$THEME/application-style.conf" ]; then
  cp "$HYPR_THEMES/$THEME/application-style.conf" "$(paths_config hypr/application-style.conf)"
fi

_qt6ct_conf="$(paths_config qt6ct/qt6ct.conf)"
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
  _snappy_conf="$(paths_config snappy-switcher/config.ini)"
  sed -i "s|^name = .*|name = ${THEME}/theme.ini|" "$_snappy_conf"
fi

if [ -f "$BOTTOM_THEMES/$THEME/bottom.toml" ]; then
  _bottom_theme="$BOTTOM_THEMES/$THEME/bottom.toml"
  _bottom_conf="$(paths_config bottom/bottom.toml)"
  cp "$_bottom_theme" "$_bottom_conf"
  for _profile in cpu mem; do
    _profile_conf="$(paths_config "bottom/${_profile}.toml")"
    apply_bottom_theme_to_profile "$_profile_conf" "$_bottom_theme"
  done

  _native_bottom="${ARGVUS_CONFIG_HOME}/bottom"
  if [ -d "$_native_bottom" ]; then
    mkdir -p "$_native_bottom"
    cp "$_bottom_theme" "$_native_bottom/bottom.toml"
    for _profile in cpu mem; do
      _native_profile="$_native_bottom/${_profile}.toml"
      if [ ! -f "$_native_profile" ]; then
        cp "$(paths_config "bottom/${_profile}.toml")" "$_native_profile"
      fi
      apply_bottom_theme_to_profile "$_native_profile" "$_bottom_theme"
    done
  fi
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
MODE_CSS="$(paths_config waybar/mode.css)"
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
if ! sh "$(paths_config scripts/argvus/accent-switch.sh)" --theme-default; then
  printf 'Error: could not restore the default accent for %s.\n' "$THEME" >&2
  exit 1
fi

_hyprlock_theme_script="$(paths_config scripts/argvus/hyprlock-theme.sh)"
if [ -f "$_hyprlock_theme_script" ]; then
  if ! sh "$_hyprlock_theme_script" --invalidate; then
    printf 'Error: could not apply the Hyprlock theme for %s.\n' "$THEME" >&2
    exit 1
  fi
fi

# Re-apply or reset spaces override depending on theme type (float vs non-float).
_spaces_script="$(paths_config scripts/argvus/spaces-switch.sh)"
case "$THEME" in
  *-float)
    # Float themes: re-apply user's spaces override on top of theme defaults.
    if [ -f "$_spaces_script" ]; then
      if ! sh "$_spaces_script" --apply-static; then
        printf 'Error: could not re-apply the spaces override for %s.\n' "$THEME" >&2
        exit 1
      fi
    fi
    ;;
  *)
    # Non-float themes: reset spaces to theme defaults (clear user overrides).
    if [ -f "$_spaces_script" ]; then
      if ! sh "$_spaces_script" --reset all; then
        printf 'Error: could not reset spaces for %s.\n' "$THEME" >&2
        exit 1
      fi
    fi
    ;;
esac

if [ "$RUNTIME" -eq 1 ]; then
  # Reload Hyprland config
  hyprctl reload

  # Restart waybar with new theme CSS (mode.css is now clean/dark)
  argvus-sessionctl restart waybar >/dev/null 2>&1 || true
fi

# Set wallpaper for the new theme
apply_wallpaper "$_theme_wallpaper"

if [ "$RUNTIME" -eq 1 ]; then
  # Restart dunst with new theme colors
  argvus-sessionctl restart dunst >/dev/null 2>&1 || true

  # Restart snappy-switcher with new theme
  argvus-sessionctl restart snappy-switcher >/dev/null 2>&1 || true

  # Signal running kitty instances to reload config (SIGUSR1)
  for _pid in $(pgrep -x kitty 2>/dev/null); do
    kill -USR1 "$_pid" 2>/dev/null || true
  done

  # Signal running foot instances to use their dark color theme.
  for _pid in $(pgrep -x foot 2>/dev/null) $(pgrep -x footclient 2>/dev/null); do
    kill -USR1 "$_pid" 2>/dev/null || true
  done
fi

# Sidebar NOT restarted — Theme.qml picks up the new theme dynamically
# via FileView watching .active-theme.

apply_argvus_storage_theme
apply_argvus_calendar_theme

[ "$RUNTIME" -eq 1 ] && notify-send "Theme" "Switched to '${THEME}'" 2>/dev/null || true
printf "Theme '%s' applied.\n" "$THEME"
