#!/usr/bin/env sh
# icon-switch - apply the configured icon theme to GNOME/GTK and Qt
# Usage: icon-switch.sh [apply]        (also sourced by theme-switch.sh)
#
# Source of truth: /appearance/icon_theme in argvus-config. An empty value
# means the ARGVUS default of the theme mode: Argvus Dark Icons for dark
# themes and Argvus Light Icons for light themes. A configured theme that is
# not installed in /usr/share/icons, $XDG_DATA_HOME/icons or ~/.icons falls
# back to that same mode default, so the desktop never points at a missing
# theme.
# shellcheck disable=SC1090,SC1091,SC2034

ARGVUS_ICON_DEFAULT_DARK="Argvus Dark Icons"
ARGVUS_ICON_DEFAULT_LIGHT="Argvus Light Icons"

if ! command -v paths_user_config >/dev/null 2>&1; then
  ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
  . "$ARGVUS_BOOTSTRAP"
fi
if ! command -v gtk_mode_for_theme >/dev/null 2>&1; then
  ARGVUS_MANIFEST_HELPER="${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/appearance/sh/theme-manifest.sh"
  [ -r "$ARGVUS_MANIFEST_HELPER" ] && . "$ARGVUS_MANIFEST_HELPER"
fi

icon_theme_is_safe_name() {
  case "$1" in
    ''|.|..|*/*) return 1 ;;
  esac
  return 0
}

icon_theme_is_installed() {
  _name="$1"
  [ -f "/usr/share/icons/${_name}/index.theme" ] && return 0
  [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/icons/${_name}/index.theme" ] && return 0
  [ -f "$HOME/.icons/${_name}/index.theme" ] && return 0
  return 1
}

# The active theme id as the desktop records it; argvus-dark when unknown.
icon_theme_active_theme() {
  _theme="$(sed -n '1p' "${ARGVUS_CONFIG_HOME}/argvus/data/.active-theme" 2>/dev/null || true)"
  [ -n "$_theme" ] || _theme=argvus-dark
  printf '%s\n' "$_theme"
}

# The ARGVUS default icon theme of a theme id, by the mode the theme uses.
icon_theme_default_for() {
  case "$(gtk_mode_for_theme "$1")" in
    light) printf '%s\n' "$ARGVUS_ICON_DEFAULT_LIGHT" ;;
    *) printf '%s\n' "$ARGVUS_ICON_DEFAULT_DARK" ;;
  esac
}

# Prints the icon theme that should be applied for a theme id (default: the
# active theme). Never prints an empty or missing theme.
icon_theme_effective() {
  _theme="${1:-$(icon_theme_active_theme)}"
  _configured="$(argvus config get /appearance/icon_theme --raw 2>/dev/null || true)"
  _configured="$(printf '%s' "$_configured" | sed -e 's/^"//' -e 's/"$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

  if [ -z "$_configured" ] || ! icon_theme_is_safe_name "$_configured"; then
    icon_theme_default_for "$_theme"
    return 0
  fi

  if icon_theme_is_installed "$_configured"; then
    printf '%s\n' "$_configured"
  else
    printf 'icon-switch: icon theme "%s" is not installed; using the %s default\n' \
      "$_configured" "$_theme" >&2
    icon_theme_default_for "$_theme"
  fi
}

# Sets gtk-icon-theme-name in one GTK settings.ini, creating the file if needed.
icon_theme_write_gtk_setting() {
  _settings="$1"
  _icon_name="$2"
  mkdir -p "${_settings%/*}"
  if [ ! -f "$_settings" ]; then
    printf '[Settings]\n' > "$_settings"
  fi
  if grep -q '^[[:space:]]*gtk-icon-theme-name[[:space:]]*=' "$_settings"; then
    sed -i "s|^[[:space:]]*gtk-icon-theme-name[[:space:]]*=.*|gtk-icon-theme-name=${_icon_name}|" "$_settings"
  else
    printf 'gtk-icon-theme-name=%s\n' "$_icon_name" >> "$_settings"
  fi
}

# Writes icon_theme into a qt6ct.conf file when the file exists.
icon_theme_write_qt6ct() {
  _icon_name="$1"
  _qt6ct_conf="$2"
  [ -f "$_qt6ct_conf" ] || return 0
  sed -i "s|^[[:space:]]*icon_theme[[:space:]]*=.*|icon_theme=${_icon_name}|" "$_qt6ct_conf"
}

# Applies the effective icon theme to the running GNOME session and to the
# GTK 3/4 and Qt6ct settings owned by ARGVUS and by the user's native config.
icon_theme_apply() {
  _icon_name="$(icon_theme_effective)"

  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface icon-theme "$_icon_name" 2>/dev/null || true
  fi

  _native_config="${XDG_CONFIG_HOME:-$HOME/.config}"
  for _gtk_version in gtk-3.0 gtk-4.0; do
    icon_theme_write_gtk_setting "$(paths_user_config "$_gtk_version")/settings.ini" "$_icon_name"
    icon_theme_write_gtk_setting "${_native_config}/${_gtk_version}/settings.ini" "$_icon_name"
  done

  icon_theme_write_qt6ct "$_icon_name" "$(paths_config appearance/config/qt6ct/qt6ct.conf)"

  printf '%s\n' "$_icon_name"
}

main() {
  case "${1:-apply}" in
    apply) icon_theme_apply >/dev/null ;;
    *)
      printf 'Usage: icon-switch.sh [apply]\n' >&2
      return 2
      ;;
  esac
}

case "$0" in
  *icon-switch.sh) main "$@" ;;
esac
