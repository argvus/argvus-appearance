#!/bin/sh
###############################################################################
# Script: theme-package-extract.sh
# Purpose: Extract official themes to standalone Arch packages
# Usage: ./theme-package-extract.sh <theme-id> [destination]
# Author: ARGVUS Theme Migration
# Dependencies: git, sed, grep, find, mkdir, cp
#
# This script:
# 1. Validates theme ID against known families
# 2. Clones skeleton-pkg template
# 3. Copies theme files from all component repos
# 4. Generates theme.toml metadata
# 5. Validates shell scripts in the result
#
# Examples:
#   ./theme-package-extract.sh dracula
#   ./theme-package-extract.sh one-dark /tmp/themes
###############################################################################

set -u

# Colors for output (when in terminal)
if [ -t 1 ]; then
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[1;33m'
    C_RED='\033[0;31m'
    C_RESET='\033[0m'
else
    C_GREEN=''
    C_YELLOW=''
    C_RED=''
    C_RESET=''
fi

# ============================================================================
# Configuration
# ============================================================================

# Get absolute path of this script
# Script is at: $WORKSPACE_ROOT/de/argvus-appearance/tools/sh/theme-package-extract.sh
_script_path="$0"
if [ ! -d "$_script_path" ]; then
    _script_path="$(cd -- "$(dirname -- "$_script_path")" && pwd)/$(basename -- "$_script_path")"
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "$_script_path")" && pwd)" || exit 1
# Go up 4 levels: sh -> tools -> argvus-appearance -> de -> workspace root
WORKSPACE_ROOT="$(cd -- "$SCRIPT_DIR/../../../.." && pwd)" || exit 1
DE_ROOT="$WORKSPACE_ROOT/de"
SKELETON_SOURCE="/seagate/gitea/repos/argvus/skeleton-pkg.git"

# Theme metadata - Dark themes (14 total - 1 argvus-dark built-in = 13 packages)
DARK_THEMES="one-dark dracula silver-dark slate-dark universe gruvbox-high-dark gruvbox-dark rose-pine tokyo-night solitude sunset hackerman monokai-dark"

# Theme metadata - Light themes (8 total - 1 argvus-light built-in = 7 packages)
LIGHT_THEMES="github-light solarized-light one-light everforest-light frost catppuccin-latte gruvbox-light"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    printf '%bℹ %s%b\n' "$C_GREEN" "$1" "$C_RESET" >&2
}

log_warn() {
    printf '%b⚠ %s%b\n' "$C_YELLOW" "$1" "$C_RESET" >&2
}

log_error() {
    printf '%b✗ %s%b\n' "$C_RED" "$1" "$C_RESET" >&2
}

usage() {
    cat >&2 <<'USAGE'
Usage: theme-package-extract.sh [OPTIONS] <theme-id>

Arguments:
  <theme-id>         Theme ID to extract (e.g., dracula, one-dark)

Options:
  -d, --dest DIR     Destination directory (default: ./de)
  -l, --list         List all known theme IDs
  -h, --help         Show this help

Examples:
  ./theme-package-extract.sh dracula
  ./theme-package-extract.sh one-dark -d /tmp/themes
USAGE
    exit "${1:-1}"
}

list_themes() {
    cat >&2 <<'LIST'
Dark themes (14 total):
  Built-in: argvus-dark
  Packages: one-dark dracula silver-dark slate-dark universe
            gruvbox-high-dark gruvbox-dark rose-pine tokyo-night
            solitude sunset hackerman monokai-dark

Light themes (8 total):
  Built-in: argvus-light
  Packages: github-light solarized-light one-light everforest-light
            frost catppuccin-latte gruvbox-light
LIST
    exit 0
}

# Determine if theme_id belongs to Dark or Light category
get_theme_category() {
    local id="$1"

    # Check if in dark themes
    case " $DARK_THEMES " in
        *" $id "*)
            printf '%s\n' "dark"
            return 0
            ;;
    esac

    # Check if in light themes
    case " $LIGHT_THEMES " in
        *" $id "*)
            printf '%s\n' "light"
            return 0
            ;;
    esac

    return 1
}

# Get display name for theme (from THEME_FAMILIES hardcoded truth)
get_theme_name() {
    local id="$1"
    case "$id" in
        argvus-dark) printf '%s\n' "ARGVUS Dark" ;;
        dracula) printf '%s\n' "Dracula" ;;
        gruvbox-dark) printf '%s\n' "Gruvbox Dark" ;;
        gruvbox-high-dark) printf '%s\n' "Gruvbox High Dark" ;;
        monokai-dark) printf '%s\n' "Monokai Dark" ;;
        one-dark) printf '%s\n' "One Dark" ;;
        rose-pine) printf '%s\n' "Rosé Pine" ;;
        silver-dark) printf '%s\n' "Silver Dark" ;;
        slate-dark) printf '%s\n' "Slate Dark" ;;
        sunset) printf '%s\n' "Sunset" ;;
        tokyo-night) printf '%s\n' "Tokyo-Night" ;;
        hackerman) printf '%s\n' "Hackerman" ;;
        solitude) printf '%s\n' "Solitude" ;;
        universe) printf '%s\n' "Universe" ;;
        argvus-light) printf '%s\n' "ARGVUS Light" ;;
        catppuccin-latte) printf '%s\n' "Catppuccin Latte" ;;
        frost) printf '%s\n' "Frost" ;;
        github-light) printf '%s\n' "GitHub Light" ;;
        gruvbox-light) printf '%s\n' "Gruvbox Light" ;;
        solarized-light) printf '%s\n' "Solarized Light" ;;
        one-light) printf '%s\n' "One Light" ;;
        everforest-light) printf '%s\n' "Everforest Light" ;;
        *) printf '%s\n' "$id" ;;
    esac
}

# Extract accent color from accent-switch.sh
get_theme_accent() {
    local id="$1"
    local accent_file="$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/sh/accent-switch.sh"

    if [ ! -f "$accent_file" ]; then
        printf '#3590bd'
        return 0
    fi

    # Look for the pattern: "    $id|$id-float) printf '...\n' ;;"
    local result
    result=$(grep "^    $id|$id-float)" "$accent_file" 2>/dev/null | sed "s/.*printf '//" | sed "s/\\\\n.*//" || printf '')

    if [ -n "$result" ]; then
        printf '%s\n' "$result"
    else
        printf '#3590bd'
    fi
}

# Extract wallpaper from hypr.sh
get_theme_wallpaper() {
    local id="$1"
    local hypr_file="$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/sh/hypr.sh"

    if [ ! -f "$hypr_file" ]; then
        printf "abstract/dark/%s-abstract-dark.jxl" "$id"
        return 0
    fi

    # Look for the pattern: "    $id) _wallpaper_name="...""
    local result
    result=$(grep "^    $id) _wallpaper_name=" "$hypr_file" 2>/dev/null \
        | sed 's/.*_wallpaper_name="//' | sed 's/".*//' || printf '')

    if [ -n "$result" ]; then
        printf '%s\n' "$result"
    else
        printf "abstract/dark/%s-abstract-dark.jxl" "$id"
    fi
}

# Validate theme ID format (alphanumeric and hyphens only)
validate_theme_id() {
    local id="$1"

    # Check against known families
    if ! get_theme_category "$id" >/dev/null 2>&1; then
        log_error "Unknown theme ID: $id"
        log_info "Use --list to see all available themes"
        return 1
    fi

    return 0
}

# ============================================================================
# Main Logic
# ============================================================================

main() {
    local theme_id=""
    local dest_dir="./de"

    # Parse arguments
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                usage 0
                ;;
            -l|--list)
                list_themes
                ;;
            -d|--dest)
                dest_dir="$2"
                shift 2
                ;;
            -*)
                log_error "Unknown option: $1"
                usage 1
                ;;
            *)
                if [ -z "$theme_id" ]; then
                    theme_id="$1"
                    shift
                else
                    log_error "Unexpected argument: $1"
                    usage 1
                fi
                ;;
        esac
    done

    # Validate arguments
    if [ -z "$theme_id" ]; then
        log_error "Missing theme ID"
        usage 1
    fi

    # Validate theme ID
    if ! validate_theme_id "$theme_id"; then
        exit 1
    fi

    # Determine output path
    local pkg_name="argvus-theme-$theme_id"
    local pkg_path="$dest_dir/$pkg_name"

    log_info "Extracting theme: $theme_id"

    # Check if already exists
    if [ -d "$pkg_path" ]; then
        log_error "Package already exists: $pkg_path"
        log_info "Use --dest to specify a different location or delete the existing package"
        exit 1
    fi

    # Verify skeleton source exists
    if [ ! -d "$SKELETON_SOURCE" ]; then
        log_error "Skeleton template not found: $SKELETON_SOURCE"
        exit 1
    fi

    # Create parent directory if needed
    if [ ! -d "$dest_dir" ]; then
        mkdir -p "$dest_dir" || {
            log_error "Failed to create destination directory: $dest_dir"
            exit 1
        }
    fi

    # Clone skeleton template
    log_info "Cloning skeleton template..."
    if ! git clone "$SKELETON_SOURCE" "$pkg_path" 2>&1 | grep -v "Cloning into" >&2; then
        log_error "Failed to clone skeleton template"
        rm -rf "$pkg_path"
        exit 1
    fi

    # Remove git metadata
    rm -rf "$pkg_path/.git" || {
        log_error "Failed to clean git metadata"
        exit 1
    }

    log_info "Cloned skeleton to: $pkg_path"

    # Get theme metadata
    local category
    category=$(get_theme_category "$theme_id") || {
        log_error "Failed to determine theme category"
        rm -rf "$pkg_path"
        exit 1
    }

    local display_name
    display_name=$(get_theme_name "$theme_id")

    local accent
    accent=$(get_theme_accent "$theme_id")

    local wallpaper
    wallpaper=$(get_theme_wallpaper "$theme_id")

    log_info "Theme metadata: category=$category, name=$display_name, accent=$accent"

    # Copy theme files from each component repository
    log_info "Copying theme files from component repositories..."

    # Create appearance directories
    mkdir -p "$pkg_path/src/usr/share/argvus/appearance/config/hypr/themes/$theme_id" || {
        log_error "Failed to create appearance hypr directory"
        rm -rf "$pkg_path"
        exit 1
    }
    mkdir -p "$pkg_path/src/usr/share/argvus/appearance/config/qt6ct/colors" || {
        log_error "Failed to create appearance qt6ct directory"
        rm -rf "$pkg_path"
        exit 1
    }
    mkdir -p "$pkg_path/src/usr/share/argvus/appearance/config/tui/themes" || {
        log_error "Failed to create appearance tui directory"
        rm -rf "$pkg_path"
        exit 1
    }

    # Copy appearance hypr config (base and float)
    if [ -d "$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/config/hypr/themes/$theme_id" ]; then
        cp -r "$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/config/hypr/themes/$theme_id/"* \
            "$pkg_path/src/usr/share/argvus/appearance/config/hypr/themes/$theme_id/" 2>/dev/null || log_warn "Could not copy hypr config for $theme_id"
    fi

    if [ -d "$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/config/hypr/themes/${theme_id}-float" ]; then
        mkdir -p "$pkg_path/src/usr/share/argvus/appearance/config/hypr/themes/${theme_id}-float"
        cp -r "$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/config/hypr/themes/${theme_id}-float/"* \
            "$pkg_path/src/usr/share/argvus/appearance/config/hypr/themes/${theme_id}-float/" 2>/dev/null || log_warn "Could not copy hypr config for ${theme_id}-float"
    fi

    # Copy appearance tui themes
    [ -f "$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/config/tui/themes/$theme_id.css" ] && \
        cp "$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/config/tui/themes/$theme_id.css" \
           "$pkg_path/src/usr/share/argvus/appearance/config/tui/themes/" 2>/dev/null || log_warn "Missing tui theme: $theme_id.css"

    [ -f "$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/config/tui/themes/${theme_id}-float.css" ] && \
        cp "$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/config/tui/themes/${theme_id}-float.css" \
           "$pkg_path/src/usr/share/argvus/appearance/config/tui/themes/" 2>/dev/null || log_warn "Missing tui theme: ${theme_id}-float.css"

    # Copy appearance qt6ct colors
    [ -f "$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/config/qt6ct/colors/$theme_id.conf" ] && \
        cp "$DE_ROOT/argvus-appearance/src/usr/share/argvus/appearance/config/qt6ct/colors/$theme_id.conf" \
           "$pkg_path/src/usr/share/argvus/appearance/config/qt6ct/colors/" 2>/dev/null || log_warn "Missing qt6ct color: $theme_id.conf"

    # Copy component-specific theme files (taskbar, launcher, etc.)
    _copy_component_themes "$pkg_path" "$theme_id" "argvus-taskbar" "taskbar/config/themes" || true
    _copy_component_themes "$pkg_path" "$theme_id" "argvus-launcher" "launcher/config/themes" || true
    _copy_component_themes "$pkg_path" "$theme_id" "argvus-widget-telemetry" "widget-telemetry/config/themes" || true
    _copy_component_themes "$pkg_path" "$theme_id" "argvus-notifications" "notifications/config/themes" || true
    _copy_component_themes "$pkg_path" "$theme_id" "argvus-terminal" "terminal/config/themes" || true
    _copy_component_themes "$pkg_path" "$theme_id" "argvus-lock" "lock/config/themes" || true
    # Control panel: corrected path with "control-panel" directory level
    _copy_component_themes "$pkg_path" "$theme_id" "argvus-control-panel" "control-panel/config/quickshell/argvus-control-panel/themes" || true

    # Copy app-profiles theme files (superfile, yazi)
    _copy_app_profile_themes "$pkg_path" "$theme_id" || true

    # Copy taskbar-calendar theme
    _copy_calendar_theme "$pkg_path" "$theme_id" || true

    # Copy wallpapers (optional, warn if missing)
    _copy_wallpapers "$pkg_path" "$theme_id" "$category" || log_warn "Wallpaper not found or incomplete for $theme_id"

    # Copy system-monitor (btop) themes (optional)
    _copy_system_monitor_theme "$pkg_path" "$theme_id" || log_warn "System monitor theme not found for $theme_id (optional)"

    # Generate theme.toml manifest
    _generate_theme_toml "$pkg_path" "$theme_id" "$category" "$display_name" "$accent" "$wallpaper" || {
        log_error "Failed to generate theme.toml"
        rm -rf "$pkg_path"
        exit 1
    }

    log_info "✓ Theme extraction complete: $pkg_path"
    log_info "Next: review and commit the package"

    return 0
}

# Copy theme directories from a component repository
_copy_component_themes() {
    local pkg_path="$1"
    local theme_id="$2"
    local component="$3"
    local theme_subpath="$4"

    local source_base="$DE_ROOT/$component/src/usr/share/argvus"
    local source_dir="$source_base/$theme_subpath"
    local dest_base="$pkg_path/src/usr/share/argvus"
    local dest_dir="$dest_base/$theme_subpath"

    # Copy base theme
    if [ -d "$source_dir/$theme_id" ]; then
        mkdir -p "$dest_dir"
        cp -r "$source_dir/$theme_id" "$dest_dir/" 2>/dev/null || log_warn "Could not copy $component theme: $theme_id"
    fi

    # Copy float variant
    if [ -d "$source_dir/${theme_id}-float" ]; then
        mkdir -p "$dest_dir"
        cp -r "$source_dir/${theme_id}-float" "$dest_dir/" 2>/dev/null || log_warn "Could not copy $component theme: ${theme_id}-float"
    fi
}

# Copy app-profiles theme files (superfile, yazi, snappy-switcher)
_copy_app_profile_themes() {
    local pkg_path="$1"
    local theme_id="$2"
    local source_base="$DE_ROOT/argvus-app-profiles/src/usr/share/argvus/app-profiles/config"

    # Superfile themes
    mkdir -p "$pkg_path/src/usr/share/argvus/app-profiles/config/superfile"
    [ -f "$source_base/superfile/theme/$theme_id.toml" ] && \
        cp "$source_base/superfile/theme/$theme_id.toml" \
           "$pkg_path/src/usr/share/argvus/app-profiles/config/superfile/" 2>/dev/null || log_warn "Missing superfile theme: $theme_id.toml"

    # Yazi themes
    mkdir -p "$pkg_path/src/usr/share/argvus/app-profiles/config/yazi/flavors"
    [ -d "$source_base/yazi/flavors/$theme_id.yazi" ] && \
        cp -r "$source_base/yazi/flavors/$theme_id.yazi" \
              "$pkg_path/src/usr/share/argvus/app-profiles/config/yazi/flavors/" 2>/dev/null || log_warn "Missing yazi flavor: $theme_id.yazi"

    # Snappy-switcher themes (if they exist)
    mkdir -p "$pkg_path/src/usr/share/argvus/app-profiles/config/snappy-switcher/themes"
    [ -d "$source_base/snappy-switcher/themes/$theme_id" ] && \
        cp -r "$source_base/snappy-switcher/themes/$theme_id" \
              "$pkg_path/src/usr/share/argvus/app-profiles/config/snappy-switcher/themes/" 2>/dev/null || log_warn "Missing snappy-switcher theme: $theme_id (optional)"
}

# Copy taskbar-calendar theme
_copy_calendar_theme() {
    local pkg_path="$1"
    local theme_id="$2"
    local source_base="$DE_ROOT/argvus-taskbar-calendar"

    mkdir -p "$pkg_path/etc/argvus/taskbar/calendar/themes"
    [ -f "$source_base/resources/themes/$theme_id.css" ] && \
        cp "$source_base/resources/themes/$theme_id.css" \
           "$pkg_path/etc/argvus/taskbar/calendar/themes/" 2>/dev/null || log_warn "Missing calendar theme: $theme_id.css"
}

# Copy wallpapers (abstract and landscape)
_copy_wallpapers() {
    local pkg_path="$1"
    local theme_id="$2"
    local category="$3"
    local source_base="$DE_ROOT/argvus-wallpapers/src/usr/share/backgrounds/argvus"

    mkdir -p "$pkg_path/src/usr/share/backgrounds/argvus/abstract/$category" 2>/dev/null

    # Copy abstract wallpaper for this theme/category
    if [ -d "$source_base/abstract/$category" ]; then
        find "$source_base/abstract/$category" -maxdepth 1 -name "*$theme_id*" -type f 2>/dev/null | while read -r wallpaper; do
            cp "$wallpaper" "$pkg_path/src/usr/share/backgrounds/argvus/abstract/$category/" 2>/dev/null || true
        done
    fi
    return 0
}

# Copy system-monitor (btop) themes
_copy_system_monitor_theme() {
    local pkg_path="$1"
    local theme_id="$2"
    local source_base="$DE_ROOT/argvus-system-monitor/src/usr/share/argvus/system-monitor"

    if [ -d "$source_base/config/btop/themes/$theme_id" ]; then
        mkdir -p "$pkg_path/src/usr/share/argvus/system-monitor/config/btop/themes"
        cp -r "$source_base/config/btop/themes/$theme_id" \
              "$pkg_path/src/usr/share/argvus/system-monitor/config/btop/themes/" 2>/dev/null || true
    fi
    return 0
}

# Generate theme.toml manifest
_generate_theme_toml() {
    local pkg_path="$1"
    local theme_id="$2"
    local category="$3"
    local display_name="$4"
    local accent="$5"
    local wallpaper="$6"

    local manifest_dir="$pkg_path/src/usr/share/argvus/appearance/themes.d/$theme_id"
    mkdir -p "$manifest_dir" || return 1

    local manifest_file="$manifest_dir/theme.toml"

    cat > "$manifest_file" <<MANIFEST
# Theme: $display_name
# Generated by theme-package-extract.sh
# Schema for /usr/share/argvus/appearance/themes.d/<id>/theme.toml

id = "$theme_id"
name = "$display_name"
category = "$category"
accent = "$accent"
wallpaper = "$wallpaper"

[name_i18n]
en-US = "$display_name"
pt-BR = "$display_name"

[palette]
# RGB hex colors for splash and greeter rendering
# bg: background color, fg: foreground, accent: highlight
# To be populated from theme assets (hyprlock.conf, etc)
bg = ""
fg = ""
accent = ""

[appearance]
# GTK theme mapping (Adwaita|Adwaita-dark)
gtk_scheme = "prefer-$category"

# Background color for effects/wallpaper fallback
background = ""

# Calendar CSS variant identifier (may differ from theme id)
calendar_css = "$theme_id"

# Removable devices CSS variant (may differ from theme id)
removable_devices_css = "$theme_id"

[aliases]
# Legacy theme ID mappings (if any) - format: "old-id" = "$theme_id"
# Example: "argvus-dark-silver" = "silver-dark"
MANIFEST

    log_info "Generated theme.toml: $manifest_file"
    return 0
}

main "$@"
