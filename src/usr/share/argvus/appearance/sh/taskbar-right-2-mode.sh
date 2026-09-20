#!/usr/bin/env sh
# Persist and apply the taskbar utility-group presentation mode.
# Usage: taskbar-right-2-mode.sh {status|set <auto|always-expanded>|apply}
# shellcheck shell=sh disable=SC1090,SC1091,SC2034

set -eu

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"
ARGVUS_MUTABLE_CONFIG=1

MODE_FILE="${ARGVUS_STATE_HOME}/taskbar-right-2-mode"

mode() {
  if [ -r "$MODE_FILE" ]; then
    case "$(sed -n '1p' "$MODE_FILE")" in
      auto|always-expanded) sed -n '1p' "$MODE_FILE"; return 0 ;;
    esac
  fi
  printf '%s\n' auto
}

apply_mode() {
  _taskbar_config="$(paths_config taskbar/config/argvus-taskbar.jsonc)"
  [ -f "$_taskbar_config" ] || {
    printf '%s\n' "missing taskbar configuration: $_taskbar_config" >&2
    return 1
  }

  case "$(mode)" in
    auto)
      sed -i '/ARGVUS_RIGHT_2_AUTO_BEGIN/,/ARGVUS_RIGHT_2_AUTO_END/{
        /ARGVUS_RIGHT_2_AUTO_BEGIN/b
        /ARGVUS_RIGHT_2_AUTO_END/b
        s|^//||
      }' "$_taskbar_config"
      sed -i 's|^//\([[:space:]]*"custom/right-2-expander",\)$|\1|' "$_taskbar_config"
      ;;
    always-expanded)
      sed -i '/ARGVUS_RIGHT_2_AUTO_BEGIN/,/ARGVUS_RIGHT_2_AUTO_END/{
        /ARGVUS_RIGHT_2_AUTO_BEGIN/b
        /ARGVUS_RIGHT_2_AUTO_END/b
        s|^|//|
      }' "$_taskbar_config"
      sed -i 's|^\([[:space:]]*"custom/right-2-expander",\)$|//\1|' "$_taskbar_config"
      ;;
  esac
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
        mkdir -p "${MODE_FILE%/*}"
        _temporary_mode_file="$(mktemp "${MODE_FILE}.tmp.XXXXXX")"
        printf '%s\n' "$2" > "$_temporary_mode_file"
        mv "$_temporary_mode_file" "$MODE_FILE"
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
