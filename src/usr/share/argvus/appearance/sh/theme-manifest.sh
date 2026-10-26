# Shared theme helpers for the appearance scripts.
#
# A theme is described by its manifest (`themes/<id>/theme.toml`), which
# `argvus config` reads; the scripts ask it instead of parsing the file.

# The GTK mode (`light` or `dark`) of a theme; the Float variant shares its family's.
gtk_mode_for_theme() {
  argvus config theme-gtk-mode "$1"
}
