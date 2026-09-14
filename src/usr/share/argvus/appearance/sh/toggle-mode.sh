#!/usr/bin/env sh

# shellcheck disable=SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"
ARGVUS_HYPR_HELPER="${ARGVUS_SYSTEM_CONFIG}/appearance/sh/hypr.sh"
[ -r "$ARGVUS_HYPR_HELPER" ] && . "$ARGVUS_HYPR_HELPER"
ARGVUS_MUTABLE_CONFIG=1

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

ARGVUS_APPS_FONT="$(font_state_value apps_name "$(font_state_value default_name "IBM Plex Mono")") $(font_state_value apps_size "$(font_state_value default_size 12)")"

native_config_home() {
  printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}"
}

replace_or_append_ini_setting() {
  _file="$1"
  _key="$2"
  _value="$3"

  mkdir -p "$(dirname "$_file")"
  [ -f "$_file" ] || printf '[Settings]\n' > "$_file"

  if grep -q "^${_key}=" "$_file"; then
    sed -i "s|^${_key}=.*|${_key}=${_value}|" "$_file"
  else
    printf '%s=%s\n' "$_key" "$_value" >> "$_file"
  fi
}

apply_gtk_settings_files() {
  _mode="$1"
  _theme="$2"
  _prefer_dark="$3"

  for _gtk_version in gtk-3.0 gtk-4.0; do
    for _settings in \
      "$(paths_user_config "$_gtk_version")/settings.ini" \
      "$(native_config_home)/${_gtk_version}/settings.ini"; do
      replace_or_append_ini_setting "$_settings" gtk-theme-name "$_theme"
      replace_or_append_ini_setting "$_settings" gtk-application-prefer-dark-theme "$_prefer_dark"
      replace_or_append_ini_setting "$_settings" gtk-icon-theme-name "Argvus Icons"
      replace_or_append_ini_setting "$_settings" gtk-font-name "$ARGVUS_APPS_FONT"
      replace_or_append_ini_setting "$_settings" gtk-cursor-theme-name Adwaita
      replace_or_append_ini_setting "$_settings" gtk-cursor-theme-size 24
    done
  done

  GTK_MODE_FILE="$ARGVUS_CONFIG_HOME/argvus/.gtk-mode"
  mkdir -p "$(dirname "$GTK_MODE_FILE")"
  printf '%s\n' "$_mode" > "$GTK_MODE_FILE"
}

# Toggle GTK dark/light mode
current="$(gsettings get org.gnome.desktop.interface color-scheme)"

if [ "$current" = "'prefer-dark'" ]; then
  gsettings set org.gnome.desktop.interface color-scheme prefer-light
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
  gsettings set org.gnome.desktop.interface icon-theme "Argvus Icons"
  gsettings set org.gnome.desktop.interface font-name "$ARGVUS_APPS_FONT"
  gsettings set org.gnome.desktop.interface document-font-name "$ARGVUS_APPS_FONT"
  MODE="light"
  apply_gtk_settings_files "$MODE" Adwaita 0
else
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
  gsettings set org.gnome.desktop.interface icon-theme "Argvus Icons"
  gsettings set org.gnome.desktop.interface font-name "$ARGVUS_APPS_FONT"
  gsettings set org.gnome.desktop.interface document-font-name "$ARGVUS_APPS_FONT"
  MODE="dark"
  apply_gtk_settings_files "$MODE" Adwaita-dark 1
fi

# Read current theme
THEME="$(cat "$ARGVUS_CONFIG_HOME/argvus/.active-theme" 2>/dev/null || echo "argvus-dark-aether")"
HYPRPAPER_FILE="$(paths_config appearance/config/hypr/hyprpaper.conf)"
HYPRPAPER_DIR="/usr/share/backgrounds/argvus"

apply_wallpaper_runtime() {
  _wall="$1"
  hypr_apply_wallpaper "$_wall"
}

get_active_monitor() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl monitors 2>/dev/null |
      sed -n 's/^Monitor \([^ ]*\).*/\1/p' |
      head -n1
  fi
}

apply_wallpaper() {
  _wall="$1"
  [ -z "$_wall" ] && return 0

  _config_path=$(printf '%s\n' "$_wall" | sed "s|^$HOME|~|")
  _monitor="$(get_active_monitor)"

  if [ -n "$_monitor" ]; then
    sed -i "s|^[[:space:]]*monitor[[:space:]]*=.*$|  monitor = ${_monitor}|" \
      "$HYPRPAPER_FILE" 2>/dev/null || true
  fi

  sed -i "s|^[[:space:]]*path[[:space:]]*=.*$|  path =  ${_config_path}|" \
    "$HYPRPAPER_FILE" 2>/dev/null || true

  apply_wallpaper_runtime "$_wall"
}

find_theme_wallpaper() {
  _theme="$1"
  case "$_theme" in
    argvus-dark-aether|argvus-dark-aether-float) _wall_name="default.png" ;;
    argvus-dark-silver|argvus-dark-silver-float) _wall_name="argvus-dark-silver.png" ;;
    argvus-light-veil|argvus-light-veil-float) _wall_name="argvus-light-veil.png" ;;
    argvus-dark-slate|argvus-dark-slate-float) _wall_name="argvus-dark-slate.png" ;;
    argvus-dark-universe|argvus-dark-universe-float) _wall_name="argvus-dark-universe.png" ;;
    *) return 1 ;;
  esac

  _wall="${HYPRPAPER_DIR}/${_wall_name}"
  [ -f "$_wall" ] || return 1
  printf '%s\n' "$_wall"
}

# ==============================================================================
# WAYBAR — mode.css
# ==============================================================================
MODE_CSS="$(paths_config appearance/config/waybar/mode.css)"
mkdir -p "$(dirname "$MODE_CSS")"

if [ "$MODE" = "light" ] && [ "$THEME" = "argvus-dark-aether" ]; then
  cat > "$MODE_CSS" << 'CSSEOF'
/* mode.css — Light mode overrides for argvus-dark-aether */

/* -- waybar/argvus-taskbar.css variables -- */
@define-color th-foreground      #181818;
@define-color th-foreground2     #181818;
@define-color th-decorate        #999999;
@define-color th-decorate-rgba   rgba(153, 153, 153, 0.45);
@define-color th-hover           #181818;
@define-color th-background      #cccccc;
@define-color th-background-rgba rgba(204, 204, 204, 1);
@define-color th-right1-bg       #b0b0b0;
@define-color th-right02-bg      #bfbfbf;
@define-color th-border-rights   rgba(153, 153, 153, 0.5);
@define-color th-window-fg       #181818;

@define-color th-danger          #181818;
@define-color th-warn            #181818;
@define-color th-ok              #555555;
@define-color th-recording       #181818;
@define-color th-recording-pause #aaaaaa;
@define-color th-power           #181818;

@define-color th-mpris-bg        #bfbfbf;
@define-color th-mpris-border    rgba(153, 153, 153, 0.5);
@define-color th-mpris-fg-anim   #181818;

/* -- waybar/argvus-widget-telemetry.css variables -- */
@define-color th-header          #181818;
@define-color th-window-bg       #b0b0b0;
@define-color th-border          #181818;
@define-color th-border-header   #181818;
@define-color th-disconnected    rgba(200, 200, 200, 0.3);
CSSEOF
else
  printf '/* mode.css — Dark mode (no overrides) */\n' > "$MODE_CSS"
fi

# Restart waybar under the ARGVUS session target.
argvus-sessionctl restart waybar >/dev/null 2>&1 || true

# ==============================================================================
# WALLPAPER
# ==============================================================================
THEME_WALLPAPER="$(find_theme_wallpaper "$THEME")" || {
  printf 'Wallpaper not found for theme: %s\n' "$THEME" >&2
  exit 1
}
apply_wallpaper "$THEME_WALLPAPER"

# ==============================================================================
# ROFI — mode.rasi
# ==============================================================================
MODE_RASI="$(paths_config launcher/config/mode.rasi)"
mkdir -p "$(dirname "$MODE_RASI")"

if [ "$MODE" = "light" ] && [ "$THEME" = "argvus-dark-aether" ]; then
  cat > "$MODE_RASI" << 'RASIEOC'
* {
    th-bg:            rgba(204, 204, 204, 100%);
    th-fg:            rgb(24, 24, 24);
    th-fg-selected:   rgb(204, 204, 204);
    th-row-alt:       rgba(176, 176, 176, 0.5);
    th-row-selected:  rgba(24, 24, 24, 0.9);
    th-border-color:  rgb(24, 24, 24);
    th-separator:     rgba(24, 24, 24, 0.5);
}
RASIEOC
else
  printf '/* mode.rasi — Dark mode (no overrides) */\n' > "$MODE_RASI"
fi

# ==============================================================================
# QUICKSHELL — .gtk-mode flag
# ==============================================================================
