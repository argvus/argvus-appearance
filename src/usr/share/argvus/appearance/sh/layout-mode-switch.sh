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

# The theme transaction (argvus-config theme-apply) holds this same lock file. Taking
# it here keeps a mode switch from interleaving its file writes with a theme switch.
if [ -n "${ARGVUS_CACHE_HOME:-}" ]; then
  LOCK_DIR="$ARGVUS_CACHE_HOME"
else
  LOCK_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/argvus"
fi
mkdir -p "$LOCK_DIR"
exec 9>>"$LOCK_DIR/theme-switch.lock"
flock -x 9

# /layout/variant is the only place Sticky/Float is persisted; this also
# resets the canonical /layout/window and /layout/taskbar geometry to the new
# mode's defaults, exactly like a theme switch already does. Selecting a
# theme never touches this value (see the theme transaction), so this is the single
# writer of the mode.
if command -v argvus >/dev/null 2>&1; then
  argvus config apply-mode "$VARIANT"
fi

ACTIVE_FILE="${ARGVUS_CONFIG_HOME}/argvus/data/.active-theme"
DEFAULT_THEME="argvus-dark"

# The active theme family never carries the variant going forward; strip a
# legacy "-float" suffix defensively for profiles that have not migrated yet.
THEME_FAMILY="$(sed -n '1p' "$ACTIVE_FILE" 2>/dev/null || true)"
THEME_FAMILY="${THEME_FAMILY%-float}"
[ -n "$THEME_FAMILY" ] || THEME_FAMILY="$DEFAULT_THEME"

# Sticky and Float differ in the geometry of every themed file, the Hyprland gaps,
# borders and rounding, and the bar margins. The theme transaction renders the family
# again for the new mode and applies it in place: it rewrites the per-mode files,
# resets gaps and borders, reloads Hyprland and restarts only the two bars, whose
# margins are layer-shell settings. No splash and no configuration-service reload.
# Release this script's lock first (the transaction takes the same lock). The canonical
# commit is skipped: /layout/variant is already set, and a commit would reset the custom
# wallpaper. `.active-theme` is left to the transaction, which compares it with the
# mode it applies to tell that the layout changed.
exec 9>&-
if command -v argvus >/dev/null 2>&1 && ARGVUS_SKIP_CANONICAL=1 argvus theme-switch "$THEME_FAMILY"; then
  exit 0
fi

# Without the transaction, keep the legacy resolved-theme marker on the new mode.
case "$VARIANT" in
  float) printf '%s' "${THEME_FAMILY}-float" > "$ACTIVE_FILE" ;;
  *) printf '%s' "$THEME_FAMILY" > "$ACTIVE_FILE" ;;
esac
