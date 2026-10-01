#!/bin/sh
###############################################################################
# Script: theme-batch-extract.sh
# Purpose: Extract all 20 official themes to standalone Arch packages
# Usage: ./theme-batch-extract.sh [destination]
# Dependencies: theme-package-extract.sh, sh
#
# This script runs theme-package-extract.sh for each of the 20 themes
# (excluding built-in argvus-dark and argvus-light).
###############################################################################

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)" || exit 1
EXTRACTOR="$SCRIPT_DIR/theme-package-extract.sh"
DEST_DIR="${1:-./de}"

# All 20 themes that will become packages
THEMES="
  one-dark dracula silver-dark slate-dark universe gruvbox-high-dark gruvbox-dark rose-pine tokyo-night solitude sunset hackerman monokai-dark
  github-light solarized-light one-light everforest-light frost catppuccin-latte gruvbox-light
"

if [ ! -f "$EXTRACTOR" ]; then
    printf 'error: theme-package-extract.sh not found: %s\n' "$EXTRACTOR" >&2
    exit 1
fi

printf 'Extracting %d themes to: %s\n' 20 "$DEST_DIR" >&2

success_count=0
fail_count=0
failed_themes=""

for theme in $THEMES; do
    printf 'Extracting: %s\n' "$theme" >&2
    if sh "$EXTRACTOR" "$theme" -d "$DEST_DIR" >/dev/null 2>&1; then
        success_count=$((success_count + 1))
    else
        fail_count=$((fail_count + 1))
        failed_themes="$failed_themes $theme"
    fi
done

printf '\n========================================\n' >&2
printf 'Extraction complete:\n' >&2
printf '  Success: %d/20\n' "$success_count" >&2
printf '  Failed:  %d/20\n' "$fail_count" >&2

if [ $fail_count -gt 0 ]; then
    printf '  Failed themes:%s\n' "$failed_themes" >&2
    exit 1
fi

printf '\nNext steps:\n' >&2
printf '  1. Review extracted packages in: %s\n' "$DEST_DIR" >&2
printf '  2. Adjust PKGBUILD templates in each package\n' >&2
printf '  3. Run `make validate` in each package\n' >&2
printf '  4. Commit and tag releases\n' >&2

exit 0
