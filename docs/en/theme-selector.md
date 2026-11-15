---
title: Visual theme selector
---

Open `argvus theme-selector`, `argvus theme-switch` without arguments, or `SUPER + Shift + T`. The independent GTK overlay opens on the active monitor, with a central preview and neighboring cards. Search or filter All/Dark/Light; use arrows, the mouse wheel or side cards to browse. Enter or Apply theme confirms; Escape or Close cancels. Browsing never changes the desktop. Installed system and user themes share the existing catalog. A valid manifest `preview` is preferred; otherwise wallpaper and palette produce an illustrative desktop, not an exact rendering of application overrides. Missing images use palette colors. Application uses the existing theme transaction and preserves Sticky/Spaced. Failures remain visible for retry. JXL thumbnails require `djxl` from `libjxl`; derived thumbnails live under the XDG cache in `argvus/theme-selector/v2`.

Press `/` to focus or leave the search field; it receives keyboard input as soon as the selector opens. **Custom** lists themes installed by the user, while **Dark** and **Light** list system themes of each category. The search row matches the central preview width. Sticky uses square corners throughout; Spaced keeps rounded corners. The compact monospace styling follows ARGVUS desktop utilities.
