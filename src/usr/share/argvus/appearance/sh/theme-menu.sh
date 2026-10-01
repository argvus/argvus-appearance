#!/usr/bin/env sh
# Hierarchical Rofi theme selector. Themes come from `argvus-appearance themes
# list`; ARGVUS Dark/Light are built in and always offered.

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"

THEME_SWITCH="$(paths_config appearance/sh/theme-switch.sh)"
ROFI_CONFIG="$(paths_config launcher/config/config.rasi)"

# Items are read from stdin, one per line.
run_menu() {
  rofi -config "$ROFI_CONFIG" -dmenu -i -p "$1" \
    -kb-move-char-back 'Control+b' \
    -kb-move-char-forward 'Control+f' \
    -kb-accept-entry 'Return,KP_Enter,Right' \
    -kb-cancel 'Escape,Left'
}

# Prints the top-level `key = "value"` of a theme.toml (stops at the first table).
manifest_field() {
  sed -n -e '/^\[/q' -e "s/^$2[[:space:]]*=[[:space:]]*\"\\(.*\\)\"[[:space:]]*\$/\\1/p" "$1" |
    head -n 1
}

# Prints "id<TAB>name<TAB>category" lines for one category: the built-in theme
# first, then every drop-in manifest under appearance/themes.d, sorted by name.
# Reads the same manifests as the Control Center and `argvus-appearance`, so
# the menu does not depend on that binary being installed.
themes_for_category() {
  _builtin_id="argvus-$1"
  case "$1" in
    dark) _builtin_name="ARGVUS Dark" ;;
    *) _builtin_name="ARGVUS Light" ;;
  esac
  printf '%s\t%s\t%s\n' "$_builtin_id" "$_builtin_name" "$1"

  _themes_dir="$(paths_system_config appearance/themes.d)"
  for _manifest in "$_themes_dir"/*/theme.toml; do
    [ -f "$_manifest" ] || continue
    _id="$(manifest_field "$_manifest" id)"
    _name="$(manifest_field "$_manifest" name)"
    _cat="$(manifest_field "$_manifest" category)"
    [ "$_cat" = "$1" ] && [ -n "$_name" ] || continue
    case "$_id" in
      '' | argvus-dark | argvus-light | -* | *- | *-float | *[!a-z0-9-]*) continue ;;
    esac
    printf '%s\t%s\t%s\n' "$_id" "$_name" "$_cat"
  done | sort -t "$(printf '\t')" -k2,2
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
  _selected="$(printf '%s\n' "$_themes_list" |
    awk -F'\t' '{ print $2 " >" }' | run_menu "$_category")" || continue
  _selected="$(printf '%s' "$_selected" | sed 's/[[:space:]]*>[[:space:]]*$//')"
  [ -n "$_selected" ] || continue

  _theme_id="$(printf '%s\n' "$_themes_list" |
    awk -F'\t' -v name="$_selected" '$2 == name { print $1; exit }')"
  [ -n "$_theme_id" ] || continue

  # The menu only lists official themes, so picking one drops any custom accent.
  exec env ARGVUS_ACCENT_OFFICIAL=1 sh "$THEME_SWITCH" "$_theme_id" >/dev/null 2>&1
done
