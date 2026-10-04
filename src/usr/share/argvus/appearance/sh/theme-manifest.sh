# Shared reader for drop-in theme manifests (themes.d/<id>/theme.toml).
#
# A theme is described by its own manifest. Code paths consult the manifest
# before any built-in table, so a theme that ships only configuration files
# works without changes to ARGVUS scripts.

ARGVUS_THEMES_D="${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/appearance/themes.d"

# True when the installed package provides a manifest for this theme ID.
theme_manifest_exists() {
  [ -r "$ARGVUS_THEMES_D/$1/theme.toml" ]
}

# Read a top-level string key. Reading stops at the first [table] header so
# keys inside [palette] or [appearance] cannot shadow top-level keys.
theme_manifest_value() {
  theme_manifest_exists "$1" || return 1
  sed -n -e '/^\[/q' -e "s/^$2 = \"\\([^\"]*\\)\"[[:space:]]*\$/\\1/p" \
    "$ARGVUS_THEMES_D/$1/theme.toml" | head -n 1 | grep .
}

# Read a string key from one [table], e.g. theme_manifest_table_value id appearance gtk_scheme.
theme_manifest_table_value() {
  theme_manifest_exists "$1" || return 1
  sed -n "/^\[$2\]/,/^\[/p" "$ARGVUS_THEMES_D/$1/theme.toml" |
    sed -n "s/^$3 = \"\\([^\"]*\\)\"[[:space:]]*\$/\\1/p" | head -n 1 | grep .
}
