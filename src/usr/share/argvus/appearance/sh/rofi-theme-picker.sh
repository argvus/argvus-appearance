#!/usr/bin/env sh
# Simple Rofi theme picker using CLI (alternative to theme-menu.sh)
# Usage: rofi-theme-picker.sh [--mode-menu]

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

THEME_SWITCH="$(paths_config appearance/sh/theme-switch.sh)"
ROFI_CONFIG="$(paths_config launcher/config/config.rasi)"

run_menu() {
  rofi -config "$ROFI_CONFIG" -dmenu -i -p "$1" \
    -kb-move-char-back 'Control+b' \
    -kb-move-char-forward 'Control+f' \
    -kb-accept-entry 'Return,KP_Enter' \
    -kb-cancel 'Escape'
}

# Flat theme list (no categories)
_category="${1:-all}"

case "$_category" in
  dark)
    _themes="$(argvus-appearance themes list --category dark --format tsv 2>/dev/null || true)"
    # Fallback: include built-in dark theme if CLI fails (using printf for reliable tab)
    if [ -z "$_themes" ]; then
      _themes="$(printf 'argvus-dark\tARGVUS Dark\tdark\n')"
    elif ! printf '%s\n' "$_themes" | grep -q "^argvus-dark"; then
      _themes="$(printf 'argvus-dark\tARGVUS Dark\tdark\n')
$_themes"
    fi
    ;;
  light)
    _themes="$(argvus-appearance themes list --category light --format tsv 2>/dev/null || true)"
    # Fallback: include built-in light theme if CLI fails (using printf for reliable tab)
    if [ -z "$_themes" ]; then
      _themes="$(printf 'argvus-light\tARGVUS Light\tlight\n')"
    elif ! printf '%s\n' "$_themes" | grep -q "^argvus-light"; then
      _themes="$(printf 'argvus-light\tARGVUS Light\tlight\n')
$_themes"
    fi
    ;;
  *)
    _themes="$(argvus-appearance themes list --format tsv 2>/dev/null || true)"
    # Fallback: include both built-in themes if CLI fails (using printf for reliable tab)
    if [ -z "$_themes" ]; then
      _themes="$(printf 'argvus-dark\tARGVUS Dark\tdark\nargvus-light\tARGVUS Light\tlight\n')"
    else
      if ! printf '%s\n' "$_themes" | grep -q "^argvus-dark"; then
        _themes="$(printf 'argvus-dark\tARGVUS Dark\tdark\n')
$_themes"
      fi
      if ! printf '%s\n' "$_themes" | grep -q "^argvus-light"; then
        _themes="$_themes
$(printf 'argvus-light\tARGVUS Light\tlight\n')"
      fi
    fi
    ;;
esac

# Extract display names (column 2)
_menu="$(printf '%s\n' "$_themes" | awk -F'\t' '{print $2}')"

# Show menu
_selected="$(printf '%s\n' "$_menu" | run_menu "Theme")" || exit 1
[ -n "$_selected" ] || exit 1

# Map name → ID
_theme_id="$(printf '%s\n' "$_themes" | awk -F'\t' -v name="$_selected" '$2 == name {print $1; exit}')"
[ -n "$_theme_id" ] || {
  printf 'Error: Theme mapping failed\n' >&2
  exit 1
}

# Apply
exec env ARGVUS_ACCENT_OFFICIAL=1 sh "$THEME_SWITCH" "$_theme_id" >/dev/null 2>&1
