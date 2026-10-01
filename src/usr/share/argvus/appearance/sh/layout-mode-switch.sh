#!/usr/bin/env sh
# layout-mode-switch - apply Sticky/Float independently of the active theme.
# Usage: layout-mode-switch.sh <sticky|float>
# shellcheck disable=SC1090,SC1091,SC2034

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"
ARGVUS_MUTABLE_CONFIG=1

VARIANT="${1:-}"
case "$VARIANT" in
  sticky|float) ;;
  *) argvus_tr appearance layout_mode.usage >&2; exit 1 ;;
esac

# /layout/variant is the only place Sticky/Float is persisted; this also
# resets the canonical /layout/window and /layout/taskbar geometry to the new
# mode's defaults, exactly like a theme switch already does. Selecting a
# theme never touches this value (see theme-switch.sh), so this is the single
# writer of the mode.
if command -v argvus-config >/dev/null 2>&1; then
  argvus-config apply-mode "$VARIANT"
fi

ACTIVE_FILE="${ARGVUS_CONFIG_HOME}/argvus/data/.active-theme"
DEFAULT_THEME="argvus-dark"

# The active theme family never carries the variant going forward; strip a
# legacy "-float" suffix defensively for profiles that have not migrated yet.
THEME_FAMILY="$(sed -n '1p' "$ACTIVE_FILE" 2>/dev/null || true)"
THEME_FAMILY="${THEME_FAMILY%-float}"
[ -n "$THEME_FAMILY" ] || THEME_FAMILY="$DEFAULT_THEME"

case "$VARIANT" in
  float) THEME="${THEME_FAMILY}-float" ;;
  *) THEME="$THEME_FAMILY" ;;
esac

# `.active-theme` is the legacy resolved-theme marker (with the `-float`
# suffix) that theme-switch.sh also writes. Consumers that have not migrated
# to reading `/layout/variant` directly, including the Control Center's
# in-memory theme state, still key off this suffix to tell Sticky and Float
# apart, so it must track the new mode even though the theme did not change.
printf '%s' "$THEME" > "$ACTIVE_FILE"

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

ARGVUS_SYSTEM_FAMILY="$(font_state_value system_family "$(font_state_value default_family "IBM Plex Mono")")"
ARGVUS_SYSTEM_SIZE="$(font_state_value system_size "$(font_state_value default_size 13)")"

# hyprtoolkit.conf/application-style.conf are the only theme-owned files that
# differ between a theme's Sticky and Float directories: rounding only, never
# color (see appearance/config/hypr/themes/<theme>/hyprtoolkit.conf). Reapply
# them so HyprToolkit apps/Quickshell pick up the new mode's rounding without
# touching anything color-related.
HYPR_THEMES="$(paths_config appearance/config/hypr/themes)"
if [ -f "${HYPR_THEMES}/${THEME}/hyprtoolkit.conf" ]; then
  cp "${HYPR_THEMES}/${THEME}/hyprtoolkit.conf" "$(paths_config appearance/config/hypr/hyprtoolkit.conf)"
  replace_or_append_setting "$(paths_config appearance/config/hypr/hyprtoolkit.conf)" font_family "\"$ARGVUS_SYSTEM_FAMILY\""
  replace_or_append_setting "$(paths_config appearance/config/hypr/hyprtoolkit.conf)" font_size "$ARGVUS_SYSTEM_SIZE"
fi
if [ -f "${HYPR_THEMES}/${THEME}/application-style.conf" ]; then
  cp "${HYPR_THEMES}/${THEME}/application-style.conf" "$(paths_config appearance/config/hypr/application-style.conf)"
fi

# Reset window/taskbar geometry and border rounding to the new mode's
# defaults. Both scripts already derive their defaults from /layout/variant,
# independent of the theme name (see spaces-switch.sh/borders-switch.sh).
_spaces_script="$(paths_config hyprland/sh/spaces-switch.sh)"
[ -f "$_spaces_script" ] && sh "$_spaces_script" --reset
_borders_script="$(paths_config hyprland/sh/borders-switch.sh)"
[ -f "$_borders_script" ] && sh "$_borders_script" --reset

# Refresh every other mode-dependent consumer (generated Hyprland config,
# Control Panel, etc.) through the established reload mechanism, the same one
# theme-switch.sh relies on for its own final consistency pass.
if [ "${ARGVUS_NO_RUNTIME:-0}" != 1 ] && command -v systemctl >/dev/null 2>&1; then
  systemctl --user reload argvus-config.service >/dev/null 2>&1 || true
fi
