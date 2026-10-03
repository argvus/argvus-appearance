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

canonical_theme_id() {
  case "$1" in
    argvus-dark-aether) printf '%s\n' "argvus-dark" ;;
    argvus-dark-aether-float) printf '%s\n' "argvus-dark-float" ;;
    argvus-light-veil) printf '%s\n' "argvus-light" ;;
    argvus-light-veil-float) printf '%s\n' "argvus-light-float" ;;
    argvus-onedark) printf '%s\n' "one-dark" ;;
    argvus-onedark-float) printf '%s\n' "one-dark-float" ;;
    argvus-dark-dracula) printf '%s\n' "dracula" ;;
    argvus-dark-dracula-float) printf '%s\n' "dracula-float" ;;
    argvus-dark-silver) printf '%s\n' "silver-dark" ;;
    argvus-dark-silver-float) printf '%s\n' "silver-dark-float" ;;
    argvus-dark-slate) printf '%s\n' "slate-dark" ;;
    argvus-dark-slate-float) printf '%s\n' "slate-dark-float" ;;
    argvus-dark-universe) printf '%s\n' "universe" ;;
    argvus-dark-universe-float) printf '%s\n' "universe-float" ;;
    argvus-dark-gruvbox-high) printf '%s\n' "gruvbox-high-dark" ;;
    argvus-dark-gruvbox-high-float) printf '%s\n' "gruvbox-high-dark-float" ;;
    argvus-dark-gruvbox) printf '%s\n' "gruvbox-dark" ;;
    argvus-dark-gruvbox-float) printf '%s\n' "gruvbox-dark-float" ;;
    argvus-github-light) printf '%s\n' "github-light" ;;
    argvus-github-light-float) printf '%s\n' "github-light-float" ;;
    argvus-light-solarized) printf '%s\n' "solarized-light" ;;
    argvus-light-solarized-float) printf '%s\n' "solarized-light-float" ;;
    argvus-light-frost) printf '%s\n' "frost" ;;
    argvus-light-frost-float) printf '%s\n' "frost-float" ;;
    argvus-light-gruvbox) printf '%s\n' "gruvbox-light" ;;
    argvus-light-gruvbox-float) printf '%s\n' "gruvbox-light-float" ;;
    argvus-dark-rose-pine|argvus-dark-rosepine) printf '%s\n' "rose-pine" ;;
    argvus-dark-rose-pine-float|argvus-dark-rosepine-float) printf '%s\n' "rose-pine-float" ;;
    argvus-dark-tokio-night|argvus-dark-tokyo-night) printf '%s\n' "tokyo-night" ;;
    argvus-dark-tokio-night-float|argvus-dark-tokyo-night-float) printf '%s\n' "tokyo-night-float" ;;
    argvus-dark-solitude) printf '%s\n' "solitude" ;;
    argvus-dark-solitude-float) printf '%s\n' "solitude-float" ;;
    argvus-dark-sunset) printf '%s\n' "sunset" ;;
    argvus-dark-sunset-float) printf '%s\n' "sunset-float" ;;
    argvus-dark-hackerman) printf '%s\n' "hackerman" ;;
    argvus-dark-hackerman-float) printf '%s\n' "hackerman-float" ;;
    argvus-dark-monokai) printf '%s\n' "monokai-dark" ;;
    argvus-dark-monokai-float) printf '%s\n' "monokai-dark-float" ;;
    argvus-catppuccin-latte) printf '%s\n' "catppuccin-latte" ;;
    argvus-catppuccin-latte-float) printf '%s\n' "catppuccin-latte-float" ;;
    argvus-light-catppuccin-latte) printf '%s\n' "catppuccin-latte" ;;
    argvus-light-catppuccin-latte-float) printf '%s\n' "catppuccin-latte-float" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

THEME="$(canonical_theme_id "${1:-}")"

# Sticky/Float is an independent setting (/layout/variant), decoupled from
# theme selection. Callers always pass a bare family id now, but strip a
# legacy "-float" suffix defensively (older menus/profiles may still send
# one) and resolve the actual on-disk variant from the current mode instead
# of from the caller's choice, so switching themes never changes the mode.
if [ -n "$THEME" ]; then
  THEME_FAMILY="${THEME%-float}"
  if command -v argvus-config >/dev/null 2>&1; then
    THEME_VARIANT="$(argvus-config get /layout/variant --raw 2>/dev/null || true)"
  else
    THEME_VARIANT=""
  fi
  case "$THEME_VARIANT" in
    float) THEME="${THEME_FAMILY}-float" ;;
    *) THEME="$THEME_FAMILY" ;;
  esac
fi

ACTIVE_FILE="${ARGVUS_CONFIG_HOME}/argvus/data/.active-theme"
GREETER_THEME_STATE_DIR="${ARGVUS_GREETER_THEME_STATE_DIR:-/var/lib/argvus/greeter/themes}"
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

THEME_TRANSITION_ACTIVE=0
LOADING_THEME_PID=0
THEME_CONFIG_READY=0
THEME_APPLY_STATUS=0

# Services that are stopped during theme transition and must be managed on
# completion. If the theme hasn't changed (same canonical state), reload_targets
# stays empty, but these services were stopped; explicitly restart the ones that
# were active before the transition so the user-visible state remains consistent.
THEME_TRANSITION_UNITS="argvus-taskbar.service argvus-widget-telemetry.service argvus-control-panel.service argvus-dunst.service argvus-snappy-switcher.service argvus-wallpaper.service"

loading_theme_pid_file() {
  printf '%s/argvus-loading-theme.pid\n' "${XDG_RUNTIME_DIR:-/tmp}"
}

loading_theme_color() {
  _key="$1"
  _fallback="$2"
  _file="$(paths_config "appearance/config/hypr/themes/${THEME}/hyprtoolkit.conf")"
  _color=""
  if [ -f "$_file" ]; then
    _color="$(sed -n "s|^[[:space:]]*${_key}[[:space:]]*=[[:space:]]*0xFF\([[:xdigit:]]\{6\}\)[[:space:]]*$|#\1|p" "$_file" | head -n 1)"
  fi
  [ -n "$_color" ] && printf '%s\n' "$_color" || printf '%s\n' "$_fallback"
}

# Get theme metadata via CLI (fallback to file-based config if CLI unavailable)
get_theme_metadata() {
  _theme_id="$1"
  _field="$2"
  _fallback="$3"

  # Try CLI first (argvus-appearance themes get)
  if command -v argvus-appearance >/dev/null 2>&1; then
    _value="$(argvus-appearance themes get "$_theme_id" "$_field" 2>/dev/null || true)"
    [ -n "$_value" ] && printf '%s\n' "$_value" && return 0
  fi

  # Fallback: return provided fallback value
  printf '%s\n' "$_fallback"
}

loading_theme_start() {
  [ "$RUNTIME" -eq 1 ] || return 0
  _splash_bin="${ARGVUS_LOADING_THEME_BIN:-/usr/lib/argvus/loading-theme/splash}"
  [ -x "$_splash_bin" ] || {
    printf '%s\n' 'argvus-appearance: argvus-loading-theme is unavailable; continuing without overlay' >&2
    return 0
  }

  _splash_ready="${XDG_RUNTIME_DIR:-/tmp}/argvus-loading-theme.$$"
  rm -f "$_splash_ready"
  _splash_foreground="$(loading_theme_color text '#f4f4f4')"
  _splash_background="$(loading_theme_color background '#101218')"
  _splash_accent="$(loading_theme_color accent '#7aa2f7')"
  "$_splash_bin" \
    --theme "$THEME" \
    --background "$_splash_background" \
    --foreground "$_splash_foreground" \
    --accent "$_splash_accent" \
    --ready-file "$_splash_ready" &
  LOADING_THEME_PID=$!

  _splash_wait=0
  while [ ! -s "$_splash_ready" ] && kill -0 "$LOADING_THEME_PID" 2>/dev/null; do
    [ "$_splash_wait" -ge 40 ] && break
    sleep 0.05
    _splash_wait=$((_splash_wait + 1))
  done
  if [ ! -s "$_splash_ready" ]; then
    printf '%s\n' 'argvus-appearance: argvus-loading-theme did not become ready; continuing without overlay' >&2
    kill -TERM "$LOADING_THEME_PID" 2>/dev/null || true
    wait "$LOADING_THEME_PID" 2>/dev/null || true
    LOADING_THEME_PID=0
  else
    printf '%s\n' "$LOADING_THEME_PID" >"$(loading_theme_pid_file)"
  fi
  rm -f "$_splash_ready"
}

loading_theme_stop() {
  [ "$LOADING_THEME_PID" -gt 0 ] || return 0
  kill "$LOADING_THEME_PID" 2>/dev/null || true
  wait "$LOADING_THEME_PID" 2>/dev/null || true
  rm -f "$(loading_theme_pid_file)"
  LOADING_THEME_PID=0
}

record_active_units() {
  _active_units=""
  for _unit in $THEME_TRANSITION_UNITS; do
    if systemctl --user is-active --quiet "$_unit" 2>/dev/null; then
      _active_units="$_active_units $_unit"
    fi
  done
  printf '%s\n' "$_active_units"
}

restart_recorded_units() {
  _units="$1"
  for _unit in $_units; do
    [ -n "$_unit" ] && systemctl --user start "$_unit" >/dev/null 2>&1 || true
  done
}

if [ -z "$THEME" ]; then
  # The selector uses the same two-pass transaction as the removable-device
  # menu: the first Rofi closes before the model submenu opens.
  exec sh "$(paths_config appearance/sh/theme-menu.sh)"
fi

# Serialize the complete transaction, including cleanup. Close the lock FD in
# children so a wallpaper process cannot keep the next theme switch blocked.
if [ "${ARGVUS_THEME_LOCKED:-0}" != 1 ]; then
  _recorded_units=""
  if command -v systemctl >/dev/null 2>&1; then
    _recorded_units="$(record_active_units)"
  fi
  _theme_lock="$(paths_cache theme-switch.lock)"
  mkdir -p "${_theme_lock%/*}"
  loading_theme_start
  trap 'loading_theme_stop' EXIT
  env ARGVUS_THEME_LOCKED=1 ARGVUS_LOADING_THEME_EXTERNAL=1 \
    flock --exclusive --close "$_theme_lock" sh "$0" "$THEME"
  _theme_status=$?
  # Session preparation materializes files with NO_RUNTIME=1. Do not reload
  # systemd components while their startup transaction is still in progress.
  if [ "$_theme_status" -eq 0 ] \
    && [ "${ARGVUS_NO_RUNTIME:-0}" != 1 ] \
    && [ "${ARGVUS_CONFIG_SERVICE:-0}" != 1 ] \
    && [ "${ARGVUS_PROJECTING:-0}" != 1 ] \
    && command -v systemctl >/dev/null 2>&1; then
    systemctl --user reload argvus-config.service >/dev/null 2>&1 || _theme_status=$?
    # If the theme hasn't changed, reload_targets stays empty and services
    # stopped in theme_transition_begin won't be restarted. Restart the ones
    # that were active, ensuring wallpaper and other UI components come back.
    restart_recorded_units "$_recorded_units"
  fi
  loading_theme_stop
  trap - EXIT
  exit "$_theme_status"
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
    argvus_tr appearance theme.directory_missing \
      "path=$(paths_system_config "${_relative}/${_theme}")" >&2
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

font_state_value() {
  _key="$1"
  _fallback="$2"
  _fonts_file="${ARGVUS_CONFIG_HOME}/argvus/data/generated/fonts.conf"
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

theme_transition_cleanup() {
  _status="${1:-0}"
  trap - EXIT HUP INT TERM

  if [ "$THEME_TRANSITION_ACTIVE" -eq 1 ]; then
    # The reset is intentionally non-runtime while the transaction is being
    # assembled. Apply its final geometry before restarting consumers; the
    # session reload path skips projection while this lock is held.
    _spaces_script="$(paths_config hyprland/sh/spaces-switch.sh)"
    _borders_script="$(paths_config hyprland/sh/borders-switch.sh)"
    if [ -f "$_spaces_script" ] && ! sh "$_spaces_script" --apply >/dev/null 2>&1; then
      [ "$_status" -ne 0 ] || _status=1
    fi
    if [ -f "$_borders_script" ] && ! sh "$_borders_script" --apply >/dev/null 2>&1; then
      [ "$_status" -ne 0 ] || _status=1
    fi
    # Runtime application is owned by the outer argvus-config.service reload.
    # Re-entering argvus-sessionctl here used to perform a second full reload
    # while theme-switch.lock was held, leaving Hyprland exec children stuck.
    # Keep this cleanup limited to the transactional generated-file updates;
    # the outer wrapper applies the final canonical projection exactly once.
    THEME_TRANSITION_ACTIVE=0
  fi

  if [ "${ARGVUS_LOADING_THEME_EXTERNAL:-0}" != 1 ]; then
    loading_theme_stop
  fi

  if [ "$_status" -eq 0 ] && [ "$THEME_CONFIG_READY" -eq 1 ]; then
    :
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
  if [ "${ARGVUS_LOADING_THEME_EXTERNAL:-0}" != 1 ]; then
    loading_theme_start
  fi

  for _unit in $THEME_TRANSITION_UNITS; do
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
    argvus-light|argvus-light-float|github-light|github-light-float|solarized-light|solarized-light-float|one-light|one-light-float|everforest-light|everforest-light-float|frost|frost-float|catppuccin-latte|catppuccin-latte-float|gruvbox-light|gruvbox-light-float) printf '%s\n' "Adwaita" ;;
    argvus-dark-*|solitude|solitude-float) printf '%s\n' "Adwaita-dark" ;;
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
  _wall="$(argvus_theme_wallpaper "$1" 2>/dev/null || true)"
  [ -n "$_wall" ] && { printf '%s\n' "$_wall"; return 0; }

  for _ext in jpeg jpg png webp jxl; do
    _wall="${HYPR_THEMES}/${1}/wallpaper.${_ext}"
    [ -f "$_wall" ] && { printf '%s\n' "$_wall"; return 0; }
  done

  # Backward compatibility for older assets with display-case names.
  find "$HYPRPAPER_DIR" -maxdepth 1 -type f -iname "${1}.*" | head -n1
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

apply_dunst_theme() {
  _dunstrc="$(paths_config notifications/config/dunstrc)"
  _theme_helper="$(paths_system_config notifications/sh/theme.sh)"
  [ -r "$_theme_helper" ] || return 0
  # shellcheck disable=SC1090
  . "$_theme_helper"
  argvus_notifications_apply_theme "$THEME" "$_dunstrc"
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

# Sincroniza o tema do argvus-removable-devices com o tema ativo.
# Mapeia: dark -> argvus-dark.css, silver -> silver-dark.css, slate -> slate-dark.css, light -> argvus-light.css
apply_argvus_storage_theme() {
  _storage_theme_dir="$(paths_config removable-devices/config/themes)"
  _storage_theme_dest="$(paths_config removable-devices/config/theme.css)"

  # Tenta encontrar os arquivos de tema em ordem de prioridade:
  # 1. Diretório do usuário (~/.config/argvus/data/removable-devices/themes)
  # 2. Diretório canônico do sistema (/usr/share/argvus/removable-devices/config/themes)
  # 3. Diretório legado do sistema (/etc/argvus/taskbar/storage/themes)
  _theme_src=""
  case "$THEME" in
    one-dark|one-dark-float)
      _theme_name="one-dark.css" ;;
    dracula|dracula-float)
      _theme_name="dracula.css" ;;
    argvus-dark|argvus-dark-float)
      _theme_name="argvus-dark.css" ;;
    silver-dark|silver-dark-float)
    _theme_name="silver-dark.css" ;;
    slate-dark|slate-dark-float)
      _theme_name="slate-dark.css" ;;
    argvus-light|argvus-light-float)
      _theme_name="argvus-light.css" ;;
    github-light|github-light-float)
      _theme_name="github-light.css" ;;
    solarized-light|solarized-light-float)
      _theme_name="solarized-light.css" ;;
    one-light|one-light-float)
      _theme_name="argvus-light.css" ;;
    everforest-light|everforest-light-float)
      _theme_name="everforest-light.css" ;;
    frost|frost-float)
      _theme_name="frost.css" ;;
    catppuccin-latte|catppuccin-latte-float)
      _theme_name="catppuccin-latte.css" ;;
    gruvbox-light|gruvbox-light-float)
      _theme_name="gruvbox-light.css" ;;
    universe|universe-float)
      _theme_name="universe.css" ;;
    gruvbox-high-dark|gruvbox-high-dark-float)
      _theme_name="gruvbox-high-dark.css" ;;
    gruvbox-dark|gruvbox-dark-float)
      _theme_name="gruvbox-dark.css" ;;
    rose-pine|rose-pine-float)
      _theme_name="rose-pine.css" ;;
    tokyo-night|tokyo-night-float)
      _theme_name="tokyo-night.css" ;;
    solitude|solitude-float)
      _theme_name="solitude.css" ;;
    sunset|sunset-float)
      _theme_name="sunset.css" ;;
    hackerman|hackerman-float)
      _theme_name="hackerman.css" ;;
    monokai-dark|monokai-dark-float)
      _theme_name="monokai-dark.css" ;;
    *)
      return 0 ;;
  esac

  # Tenta o diretório do usuário
  if [ -f "${_storage_theme_dir}/${_theme_name}" ]; then
    _theme_src="${_storage_theme_dir}/${_theme_name}"
  # Tenta o sistema canônico
  elif [ -f "$(paths_system_config removable-devices/config/themes/${_theme_name})" ]; then
    _theme_src="$(paths_system_config removable-devices/config/themes/${_theme_name})"
  # Mantém instalações antigas funcionais durante a migração.
  elif [ -f "/etc/argvus/taskbar/storage/themes/${_theme_name}" ]; then
    _theme_src="/etc/argvus/taskbar/storage/themes/${_theme_name}"
  # Tenta o diretório do projeto argvus-removable-devices (desenvolvimento).
  elif [ -n "$_workspace_root" ] && [ -f "$_workspace_root/argvus-removable-devices/src/usr/share/argvus/removable-devices/config/themes/${_theme_name}" ]; then
    _theme_src="$_workspace_root/argvus-removable-devices/src/usr/share/argvus/removable-devices/config/themes/${_theme_name}"
  else
    # Some consumers intentionally ship a smaller palette set. Keep them in
    # sync with the active light/dark mode instead of silently retaining the
    # previous theme when a family-specific stylesheet is unavailable.
    case "$THEME" in
      argvus-light*|catppuccin-latte*|frost*|github-light*|gruvbox-light*|solarized-light*|one-light*|everforest-light*)
        _theme_name="argvus-light.css" ;;
      *)
        _theme_name="argvus-dark.css" ;;
    esac
    if [ -f "${_storage_theme_dir}/${_theme_name}" ]; then
      _theme_src="${_storage_theme_dir}/${_theme_name}"
    elif [ -f "$(paths_system_config removable-devices/config/themes/${_theme_name})" ]; then
      _theme_src="$(paths_system_config removable-devices/config/themes/${_theme_name})"
    elif [ -f "/etc/argvus/taskbar/storage/themes/${_theme_name}" ]; then
      _theme_src="/etc/argvus/taskbar/storage/themes/${_theme_name}"
    elif [ -n "$_workspace_root" ] && [ -f "$_workspace_root/argvus-removable-devices/src/usr/share/argvus/removable-devices/config/themes/${_theme_name}" ]; then
      _theme_src="$_workspace_root/argvus-removable-devices/src/usr/share/argvus/removable-devices/config/themes/${_theme_name}"
    else
      return 0
    fi
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
    one-dark|one-dark-float|dracula|dracula-float|\
    argvus-dark|argvus-dark-float|silver-dark|silver-dark-float|\
    slate-dark|slate-dark-float)
      _calendar_theme_name="${THEME}.css" ;;
    universe|universe-float)
      _calendar_theme_name="${THEME}.css" ;;
    argvus-light|argvus-light-float|github-light|github-light-float|solarized-light|solarized-light-float|one-light|one-light-float|everforest-light|everforest-light-float)
      _calendar_theme_name="${THEME}.css" ;;
    frost|frost-float)
      _calendar_theme_name="${THEME}.css" ;;
    catppuccin-latte|catppuccin-latte-float)
      _calendar_theme_name="${THEME}.css" ;;
    gruvbox-light|gruvbox-light-float|one-light|one-light-float|everforest-light|everforest-light-float)
      _calendar_theme_name="${THEME}.css" ;;
    gruvbox-high-dark|gruvbox-high-dark-float|gruvbox-dark|gruvbox-dark-float)
      _calendar_theme_name="${THEME}.css" ;;
    rose-pine|rose-pine-float|solitude|solitude-float|\
    sunset|sunset-float|hackerman|hackerman-float|\
    monokai-dark|monokai-dark-float)
      _calendar_theme_name="${THEME}.css" ;;
    tokyo-night|tokyo-night-float)
      _calendar_theme_name="tokyo-night.css" ;;
    *)
      return 0 ;;
  esac

  # Read-only lookup: paths_config would create the user theme directory even
  # when no calendar theme exists, so use paths_read_config and let the user
  # override live under data/taskbar/calendar/themes/.
  _calendar_user_theme="$(paths_read_config "taskbar/calendar/themes/${_calendar_theme_name}")"
  _calendar_theme_src=""
  if [ -f "$_calendar_user_theme" ]; then
    _calendar_theme_src="$_calendar_user_theme"
  elif [ -f "/etc/argvus/taskbar/calendar/themes/${_calendar_theme_name}" ]; then
    _calendar_theme_src="/etc/argvus/taskbar/calendar/themes/${_calendar_theme_name}"
  elif [ -n "$_workspace_root" ] && [ -f "$_workspace_root/argvus-taskbar-calendar/resources/themes/${_calendar_theme_name}" ]; then
    _calendar_theme_src="$_workspace_root/argvus-taskbar-calendar/resources/themes/${_calendar_theme_name}"
  else
    return 0
  fi

  mkdir -p "$(dirname "$_calendar_theme_cache")"
  _calendar_theme_base_src=""
  case "$_calendar_theme_name" in
    *-float.css)
      _calendar_theme_base_name="${_calendar_theme_name%-float.css}.css"
      _calendar_theme_base_src="$(dirname "$_calendar_theme_src")/${_calendar_theme_base_name}"
      [ -f "$_calendar_theme_base_src" ] || return 0
      ;;
  esac
  _calendar_theme_tmp="${_calendar_theme_cache}.$$"
  if ! {
    printf '/* argvus-theme: %s */\n' "$THEME"
    if [ -n "$_calendar_theme_base_src" ]; then
        cat "$_calendar_theme_base_src"
        sed '/^[[:space:]]*@import[[:space:]]*url(/d' "$_calendar_theme_src"
    else
      cat "$_calendar_theme_src"
    fi
  } > "$_calendar_theme_tmp"; then
    rm -f "$_calendar_theme_tmp"
    return 0
  fi
  if ! mv -f "$_calendar_theme_tmp" "$_calendar_theme_cache"; then
    rm -f "$_calendar_theme_tmp"
    return 0
  fi
  command -v argvus-taskbar-calendar >/dev/null 2>&1 && argvus-taskbar-calendar reload >/dev/null 2>&1 || true
}

# Publish only the validated theme identifier needed by the pre-authentication
# greeter. The private .active-theme remains the user-facing source of truth;
# this persistent projection avoids granting the greeter access to user homes.
publish_greeter_theme() {
  case "$THEME" in
    dracula|dracula-float|argvus-dark|argvus-dark-float|silver-dark|silver-dark-float|\
    slate-dark|slate-dark-float|universe|universe-float|\
    argvus-light|argvus-light-float|github-light|github-light-float|solarized-light|solarized-light-float|one-light|one-light-float|everforest-light|everforest-light-float|frost|frost-float|catppuccin-latte|catppuccin-latte-float|gruvbox-light|gruvbox-light-float|gruvbox-high-dark|gruvbox-high-dark-float|gruvbox-dark|gruvbox-dark-float|rose-pine|rose-pine-float|tokyo-night|tokyo-night-float|solitude|solitude-float|sunset|sunset-float|hackerman|hackerman-float|monokai-dark|monokai-dark-float)
      ;;
    *)
      return 0
      ;;
  esac

  [ -d "$GREETER_THEME_STATE_DIR" ] || return 0

  _greeter_theme_uid="$(id -u)"
  _greeter_theme_target="$GREETER_THEME_STATE_DIR/$_greeter_theme_uid"
  _greeter_theme_tmp="${_greeter_theme_target}.tmp.$$"
  if ! printf '%s\n' "$THEME" > "$_greeter_theme_tmp"; then
    rm -f -- "$_greeter_theme_tmp"
    return 0
  fi
  chmod 0644 "$_greeter_theme_tmp" 2>/dev/null || true
  if ! mv -f -- "$_greeter_theme_tmp" "$_greeter_theme_target"; then
    rm -f -- "$_greeter_theme_tmp"
  fi
}

if [ -z "$THEME" ]; then
  argvus_tr appearance theme.usage >&2
  exit 1
fi

if [ ! -f "$SUPERFILE_THEMES/$THEME.toml" ]; then
  argvus_tr appearance theme.superfile_missing \
    "path=$SUPERFILE_THEMES/$THEME.toml" >&2
fi

if [ ! -f "$QT6CT_COLORS/$THEME.conf" ]; then
  argvus_tr appearance theme.qt6ct_missing \
    "path=$QT6CT_COLORS/$THEME.conf" >&2
fi

if ! _theme_wallpaper="$(find_theme_wallpaper "$THEME")"; then
  if [ "$RUNTIME" -eq 1 ]; then
    exit 1
  fi
  _theme_wallpaper=""
fi

# Theme selection is also a write operation on the canonical configuration.
# Keep the legacy marker below as a derived compatibility projection for the
# current Hyprland Lua and shell consumers. During argvus-config projection the
# canonical mutation already happened, so calling it again would re-enter the
# transaction.
if [ "${ARGVUS_PROJECTING:-0}" != 1 ] && command -v argvus-config >/dev/null 2>&1; then
  # Clear the canonical accent override in the same transaction as the theme
  # write, so the official theme default is what gets persisted.
  if [ "${ARGVUS_ACCENT_OFFICIAL:-0}" = 1 ]; then
    _theme_accent_flag="--reset-accent"
  else
    _theme_accent_flag=""
  fi
  # /appearance/theme stores the canonical family id, never the -float
  # suffix: the variant is owned by /layout/variant (mode-switch.sh), not by
  # theme selection.
  if [ -n "$_theme_wallpaper" ]; then
    argvus-config apply-theme "$THEME_FAMILY" $_theme_accent_flag \
      --wallpaper "$_theme_wallpaper" --reset-wallpaper >/dev/null 2>&1 || true
  else
    argvus-config apply-theme "$THEME_FAMILY" $_theme_accent_flag >/dev/null 2>&1 || true
  fi
  unset _theme_accent_flag
fi

theme_transition_begin

printf '%s' "$THEME" > "$ACTIVE_FILE"
publish_greeter_theme

# ----- Per-theme waybar layout -----
# Refresh the canonical mutable copies. The previous legacy `waybar/...`
# arguments resolved against /usr/share/argvus/waybar, which no longer exists
# after the project split and left stale script paths in user configurations.
refresh_managed_waybar_file taskbar/config/argvus-taskbar.jsonc
refresh_managed_waybar_file taskbar/config/argvus-taskbar.css
refresh_managed_waybar_file widget-telemetry/config/argvus-widget-telemetry.jsonc
refresh_managed_waybar_file widget-telemetry/config/argvus-widget-telemetry.css
_taskbar_right_2_mode_script="$(paths_config appearance/sh/taskbar-right-2-mode.sh)"
if [ -x "$_taskbar_right_2_mode_script" ]; then
  "$_taskbar_right_2_mode_script" apply
fi
# The managed Waybar file is recreated above (pristine system copy), so the
# user's icon visibility and date/time format preferences must be re-derived
# from the canonical config onto it, same as after a Control Center change.
_taskbar_widgets_mode_script="$(paths_config appearance/sh/taskbar-widgets-mode.sh)"
if [ -x "$_taskbar_widgets_mode_script" ]; then
  "$_taskbar_widgets_mode_script" apply
fi
# The managed Waybar file is recreated above, so restore the user's sparse
# telemetry block preferences before the session components are restarted.
if command -v argvus-widget-telemetry-toggle >/dev/null 2>&1; then
  argvus-widget-telemetry-toggle blocks apply || true
fi
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
  one-dark | dracula | argvus-dark | silver-dark | argvus-light | github-light | solarized-light | one-light | everforest-light | frost | catppuccin-latte | gruvbox-light | slate-dark | universe | gruvbox-high-dark | gruvbox-dark | rose-pine | tokyo-night | solitude | sunset | hackerman | monokai-dark)
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
    sed -i "s|\"margin-top\": [0-9]*|\"margin-top\": 16|" "$_waybar_cfg"
    sed -i "s|\"margin-left\": [0-9]*|\"margin-left\": 16|" "$_waybar_cfg"
    sed -i "s|\"margin-right\": [0-9]*|\"margin-right\": 16|" "$_waybar_cfg"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": 0|" "$_waybar_cfg"
    sed -i "s|\"margin-top\": -\?[0-9]*|\"margin-top\": 16|" "$_waybar_cfg_widget_telemetry"
    sed -i "s|\"margin-left\": -\?[0-9]*|\"margin-left\": 16|" "$_waybar_cfg_widget_telemetry"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": 0|" "$_waybar_cfg_widget_telemetry"
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
  slate-dark)
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
#custom-removable-devices,
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

if command -v argvus-terminal >/dev/null 2>&1; then
  if ! argvus-terminal --apply "$THEME" >/dev/null 2>&1; then
    argvus_tr appearance theme.terminal_apply_failed >&2
    THEME_APPLY_STATUS=1
  fi
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
  sync_snappy_switcher_theme
fi

_yazi_theme="$THEME"
case "$THEME" in
  sunset-float) _yazi_theme='sunset' ;;
  hackerman-float) _yazi_theme='hackerman' ;;
esac

if [ -d "$YAZI_SYSTEM_ROOT/flavors/$_yazi_theme.yazi" ]; then
  mkdir -p "$YAZI_CONFIG_ROOT/flavors/$THEME.yazi"
  cp -R "$YAZI_SYSTEM_ROOT/flavors/$_yazi_theme.yazi/." "$YAZI_CONFIG_ROOT/flavors/$THEME.yazi/"
fi

if [ -f "$YAZI_CONFIG_ROOT/flavors/$THEME.yazi/flavor.toml" ]; then
  printf '[flavor]\ndark = "%s"\n' "$THEME" > "$YAZI_CONFIG_ROOT/theme.toml"
else
  argvus_tr appearance theme.yazi_missing \
    "path=$YAZI_CONFIG_ROOT/flavors/$THEME.yazi/flavor.toml" >&2
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
GTK_MODE_FILE="${ARGVUS_CONFIG_HOME}/argvus/data/.gtk-mode"
mkdir -p "$(dirname "$GTK_MODE_FILE")"
case "$THEME" in
    argvus-light | argvus-light-float | github-light | github-light-float | solarized-light | solarized-light-float | one-light | one-light-float | everforest-light | everforest-light-float | frost | frost-float | catppuccin-latte | catppuccin-latte-float | gruvbox-light | gruvbox-light-float)
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

# A theme owns its default accent, so an explicit official-theme selection
# restores the theme default and clears the canonical override. A highlight
# color the user picked deliberately is canonical state
# (`/appearance/accent_custom`) and survives every other theme change, such as
# session startup, configuration projection and custom profile applies, where
# the new theme only owns backgrounds.
if [ "${ARGVUS_ACCENT_OFFICIAL:-0}" != 1 ] \
  && command -v argvus-config >/dev/null 2>&1 \
  && [ "$(argvus-config get /appearance/accent_custom --raw 2>/dev/null)" = "true" ]; then
  _accent_mode="--apply-static"
else
  _accent_mode="--theme-default"
fi

if ! sh "$(paths_config appearance/sh/accent-switch.sh)" "$_accent_mode" >/dev/null 2>&1; then
  argvus_tr appearance theme.accent_restore_failed "theme=$THEME" >&2
  exit 1
fi

_hyprlock_theme_script="$(paths_config lock/sh/hyprlock-theme.sh)"
if [ -f "$_hyprlock_theme_script" ]; then
  if ! sh "$_hyprlock_theme_script" --invalidate >/dev/null 2>&1; then
    argvus_tr appearance theme.hyprlock_failed "theme=$THEME" >&2
    exit 1
  fi
fi

# Applying a theme resets the window/taskbar spacing to the selected mode's
# defaults. The Control Panel can then create a new user override.
_spaces_script="$(paths_config hyprland/sh/spaces-switch.sh)"
if [ -f "$_spaces_script" ]; then
  if ! ARGVUS_NO_RUNTIME=1 sh "$_spaces_script" --reset; then
    argvus_tr appearance theme.spaces_failed "theme=$THEME" >&2
    exit 1
  fi
fi

# Apply the selected mode's border defaults to both the taskbar CSS and
# Hyprland. The Control Panel can then create a new user override.
_borders_script="$(paths_config hyprland/sh/borders-switch.sh)"
if [ -f "$_borders_script" ]; then
  if ! ARGVUS_NO_RUNTIME=1 sh "$_borders_script" --reset; then
    argvus_tr appearance theme.borders_failed "theme=$THEME" >&2
    exit 1
  fi
fi

# Set wallpaper for the new theme
# A theme change is an explicit request to use the theme's wallpaper. Clear
# the independent custom selection so the new theme also remains active after
# the next logout/login cycle.
clear_custom_wallpaper
if ! apply_wallpaper "$_theme_wallpaper"; then
  argvus_tr appearance theme.wallpaper_prepare_failed "theme=$THEME" >&2
  exit 1
fi

if [ "$RUNTIME" -eq 1 ]; then
  # Signal running kitty instances to reload config (SIGUSR1)
  for _pid in $(pgrep -x kitty 2>/dev/null); do
    kill -USR1 "$_pid" 2>/dev/null || true
  done
fi

apply_argvus_storage_theme
apply_argvus_calendar_theme

# Theme application recreates managed consumer files. Reapply the persisted
# effects state last so disabled effects keep their surfaces solid, while an
# enabled state restores each theme's native transparency and blur.
_effects_script="$(paths_config session/sh/effects-toggle.sh)"
if [ -f "$_effects_script" ]; then
  sh "$_effects_script" apply >/dev/null 2>&1 || true
fi

THEME_CONFIG_READY=1
if [ "$RUNTIME" -eq 1 ]; then
  theme_transition_cleanup "$THEME_APPLY_STATUS"
else
  exit "$THEME_APPLY_STATUS"
fi
