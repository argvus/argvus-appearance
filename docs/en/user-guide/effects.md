---
title: Effects
description: Configure animations, global blur intensity and per-surface effects.
---

**Control Center → Appearance → Effects** contains only **Animations** and **Blur intensity**. Transparency and blur enable switches are per-surface settings in their respective Appearance pages.

Surface switches are independent. The Control Center Configuration page has its own Transparency value and Blur enable switch; its blur uses the global intensity.

The Control Center is launched through Foot with a dedicated generated profile at `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`. With Foot 1.28, transparency is projected to `[colors-dark] alpha` and the surface Blur switch to `[colors-dark] blur`; the normal Foot configuration and ARGVUS terminal remain independent.

## Transparency

Each surface has its own **Transparency** submenu with an enable switch and value.

The **Appearance → Launchers** page controls the official Rofi-based launcher and picker flows: the main launcher, emoji picker, calculator, clipboard picker, cheatsheets and Rofi removable-device menus. Its Transparency value is the final background alpha, so `50` means an effective background opacity of approximately `0.50`; text, icons and selected rows remain opaque. Its Blur switch opts the `rofi` layer into the existing global blur intensity.

Each value ranges from `0%` (opaque) to `100%` (fully transparent). Use `+` and `-` in 5% steps, then select **Apply** on the surface page. Leaving the page discards an un-applied draft.

Use `↑` and `↓` to move between **Enable** and **Value**. On the **Value** row, `+` and `-` adjust the draft without changing focus. Press `Tab` to open **Actions**, then activate **[ Apply ]**; `Esc` returns to the parent surface page.

## Blur

Each surface has its own **Blur** enable switch. Hyprland layer and window surfaces use one global compositor blur intensity. Use **Effects → Blur intensity**, adjust the staged value with `+` and `-` in 5% steps, then select **Apply**. The value is stored at `/effects/blur_global_value` and is shared by every enabled surface; it is not a per-surface slider.

Blur uses the same keyboard flow: `↑/↓` moves between options, `+/-` adjusts the value and `Tab` opens **Actions** to apply it.

Hyprland exposes blur radius and pass count compositor-wide, rather than allowing an independent GPU radius in each layer rule. ARGVUS maps the global value directly to those compositor parameters; each surface only opts into or out of the global blur. Changing one surface's enable switch therefore does not change global intensity.

## Canonical state and compatibility files

The logical preference is stored in `$XDG_CONFIG_HOME/argvus/config.json`. Global animation uses `effects.animations`, while blur intensity uses `effects.blur_global_value`; surface enable states and transparency values use keys such as `effects.blur_control-center_enabled` and `effects.transparency_control-center_value`. Terminal blur uses the same `effects.blur_global_value`; there is no global Blur toggle or separate terminal blur intensity. Values are clamped to `0–100` and enable states remain distinct from missing overrides.

```text
$XDG_CONFIG_HOME/argvus/config.json
```

`data/generated/effects/<active-theme>.conf` is the single projection for effects, written only by `argvus-config`; `effects-toggle.sh` is a thin delegate to `argvus-config effects` with no output of its own, and it is not a competing source of truth. Theme-specific defaults are used only when the canonical field is absent, and an explicit `false` is never treated as missing. Switching themes preserves canonical overrides and regenerates the affected projections.

Disabling a surface's Transparency or Blur switch affects only that surface; saved numeric values are retained for later re-enabling.

## Profiles

Theme export/import includes the active theme's transparency and blur values, together with the existing effect states. Inactive themes are not included in the profile. Generated Waybar, Quickshell and Hyprland runtime files are regenerated when the profile is applied.

All surface pages apply their drafts together with the `[ Apply ]` button. Control Center writes the canonical document through the effects helper, lets `argvus-config` project the effects tree, reloads affected consumers and reads the effective value back. Theme export/import includes the canonical appearance/effects scope; generated files are recreated rather than imported as authoritative state.
