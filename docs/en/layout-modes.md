---
title: Layout modes
description: Choose the Sticky or Spaced desktop layout.
---

Sticky keeps windows and shell surfaces compact. Spaced uses larger gaps, rounded corners and wider taskbar margins. The layout mode is independent of the selected theme; changing modes reapplies that mode's geometry.

Choose the mode in **Control Center → Appearance → Desktop → Appearance Mode** or open its picker with `SUPER + Shift + M`. The canonical setting is `/layout/variant`, with values `sticky` and `spaced`. Resolved Spaced theme IDs use the `-spaced` suffix. Existing `float` values and `-float` IDs remain readable for compatibility.

`argvus layout-mode-menu` (SUPER + Shift + M): **Tab / Shift+Tab**: Sticky/Spaced ⇄ Tile/Floating · Taskbar Top/Bottom. Choose Sticky or Spaced with ↑/↓. The four cards on the right combine Tile or Floating windows with Taskbar Top or Bottom; ↑/↓/←/→ moves through them without wrapping. Click a card to select it, Enter to apply, or Escape to cancel. The unselected mode is dimmed; previews use the current theme and wallpaper. Pending applications remain visible and failures can be retried.

Applications started by the theme and mode selectors keep progress inside the selector, without a session splash. Mode changes prepare the final taskbar position before reloading; required surface restarts are grouped in one systemd transaction.
