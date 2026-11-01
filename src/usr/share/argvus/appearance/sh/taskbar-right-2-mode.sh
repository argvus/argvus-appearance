#!/usr/bin/env sh
# Persist and apply the taskbar utility-group presentation mode.
# Usage: taskbar-right-2-mode.sh {status|set <auto|always-expanded>|apply}
# shellcheck shell=sh disable=SC1090,SC1091,SC2034

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"
ARGVUS_MUTABLE_CONFIG=1

# The mode is /taskbar/icons/utilities/expanded in argvus-config; the legacy
# state file is no longer read or written.
mode() {
  if command -v argvus >/dev/null 2>&1; then
    _expanded="$(argvus config get /taskbar/icons/utilities/expanded --effective --raw 2>/dev/null || true)"
    case "$_expanded" in
      true) printf '%s\n' always-expanded; return 0 ;;
      false) printf '%s\n' auto; return 0 ;;
    esac
  fi
  printf '%s\n' always-expanded
}

apply_mode() {
  # The widgets projector owns drawer and module generation together.
  # Repeated mode changes must not accumulate comment prefixes.
  "$(dirname -- "$0")/taskbar-widgets-mode.sh" apply

}

case "${1:-status}" in
  status)
    mode
    ;;
  apply)
    apply_mode
    ;;
  set)
    case "${2:-}" in
      auto|always-expanded)
        if ! command -v argvus >/dev/null 2>&1; then
          printf '%s\n' "argvus is required to store the taskbar mode" >&2
          exit 1
        fi
        _expanded=false
        [ "$2" = always-expanded ] && _expanded=true
        argvus config patch "{\"/taskbar/icons/utilities/expanded\": ${_expanded}}"
        apply_mode
        ;;
      *)
        printf '%s\n' "invalid taskbar right-2 mode: ${2:-empty}" >&2
        exit 2
        ;;
    esac
    ;;
  *)
    printf '%s\n' "usage: $0 {status|set <auto|always-expanded>|apply}" >&2
    exit 2
    ;;
esac
