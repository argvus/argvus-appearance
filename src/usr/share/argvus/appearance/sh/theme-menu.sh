#!/usr/bin/env sh
# Hierarchical Rofi theme selector. Themes come from `argvus theme list`;
# ARGVUS Dark/Light are listed first in their category.

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

ROFI_CONFIG="$(paths_config launcher/config/config.rasi)"

# Items are read from stdin, one per line.
run_menu() {
  rofi -config "$ROFI_CONFIG" -dmenu -i -p "$1" \
    -kb-move-char-back 'Control+b' \
    -kb-move-char-forward 'Control+f' \
    -kb-accept-entry 'Return,KP_Enter,Right' \
    -kb-cancel 'Escape,Left'
}

# Prints "id<TAB>name<TAB>category" lines for one category: the ARGVUS theme
# first, then every installed theme (official and the user's own, as
# `argvus theme list` discovers them), sorted by name.
themes_for_category() {
  _builtin_id="argvus-$1"
  argvus theme list 2>/dev/null |
    awk -F'\t' -v category="$1" -v builtin="$_builtin_id" '
      $2 == category && $1 == builtin { printf "%s\t%s\t%s\n", $1, $4, $2 }
    '
  argvus theme list 2>/dev/null |
    awk -F'\t' -v category="$1" -v builtin="$_builtin_id" '
      $2 == category && $1 != builtin { printf "%s\t%s\t%s\n", $1, $4, $2 }
    ' | sort -t "$(printf '\t')" -k2,2
}

_dark_category="$(argvus_tr appearance theme.category.dark)"
_light_category="$(argvus_tr appearance theme.category.light)"

while :; do
  if ! _category="$(printf '%s >\n%s >\n' "$_dark_category" "$_light_category" |
    run_menu "$(argvus_tr appearance theme.select)")"; then
    exit 0
  fi
  _category="$(printf '%s' "$_category" | sed 's/[[:space:]]*>[[:space:]]*$//')"
  [ -n "$_category" ] || exit 0

  case "$_category" in
    "$_dark_category") _cat_filter=dark ;;
    "$_light_category") _cat_filter=light ;;
    *) exit 0 ;;
  esac

  _themes_list="$(themes_for_category "$_cat_filter")"

  # Left/Escape returns to the category menu.
  # Themes are leaves, so their names are shown without a submenu marker.
  _selected="$(printf '%s\n' "$_themes_list" |
    awk -F'\t' '{ print $2 }' | run_menu "$_category")" || continue
  [ -n "$_selected" ] || continue

  _theme_id="$(printf '%s\n' "$_themes_list" |
    awk -F'\t' -v name="$_selected" '$2 == name { print $1; exit }')"
  [ -n "$_theme_id" ] || continue

  # The menu only lists official themes, so picking one drops any custom accent.
  exec env ARGVUS_ACCENT_OFFICIAL=1 argvus theme-switch "$_theme_id" >/dev/null 2>&1
done
