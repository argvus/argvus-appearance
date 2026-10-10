---
title: Effects
description: Configure animations, the global Hyprland blur and per-surface transparency.
---

**Control Center → Hyprland** contains **Animations** and **Blur**. Transparency enable switches are per-surface settings in their respective Appearance pages.

Surface switches are independent. The Control Center Configuration page has its own Transparency value and Blur enable switch; its blur uses the global Blur values.

The Control Center is launched through Foot with a dedicated generated profile at `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`. With Foot 1.28, transparency is projected to `[colors-dark] alpha` and the surface Blur switch to `[colors-dark] blur`; the normal Foot configuration and ARGVUS terminal remain independent.

## Transparency

Each surface has its own **Transparency** submenu with an enable switch and value.

The **Appearance → Launchers** page controls the official Rofi-based launcher and picker flows: the main launcher, emoji picker, calculator, clipboard picker, cheatsheets and Rofi removable-device menus. Its Transparency value is the final background alpha, so `50` means an effective background opacity of approximately `0.50`; text, icons and selected rows remain opaque. Its Blur switch opts the `rofi` layer into the global Blur settings.

Each value ranges from `0%` (opaque) to `100%` (fully transparent). Use `+` and `-` in 5% steps, then select **Apply** on the surface page. Leaving the page discards an un-applied draft.

Use `↑` and `↓` to move between **Enable** and **Value**. On the **Value** row, `+` and `-` adjust the draft without changing focus. Press `Tab` to open **Actions**, then activate **[ Apply ]**; `Esc` returns to the parent surface page.

## Blur

Blur is one global Hyprland setting, shared by every surface that opts in. Open **Control Center → Hyprland → Blur**. The page has an **Enable** switch and a **Values** list with the parameters of Hyprland's `decoration:blur`, under the names Hyprland uses:

| Row | Config key | Default | Range | `←/→` step |
|---|---|---|---|---|
| Size | `effects.blur_size` | `6` | 1–64 | 1 |
| Passes | `effects.blur_passes` | `2` | 1–8 | 1 |
| Brightness | `effects.blur_brightness` | `1` | 0–2 | 0.05 |
| Noise | `effects.blur_noise` | `0.00` | 0–1 | 0.01 |
| Contrast | `effects.blur_contrast` | `0.900000` | 0–2 | 0.05 |
| Vibrancy | `effects.blur_vibrancy` | `0.100000` | 0–1 | 0.01 |
| Vibrancy darkness | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0.01 |

Use `↑/↓` to move, `←/→` (or `+/-`) to change the selected value by its step, and `Enter` to type an exact value; values outside the range are refused. Nothing is written while you edit: the switch and the values stay in the draft until **[ Apply ]** at the bottom of the page is selected. Apply writes every changed value in one call, and reloads Hyprland after it. Leaving the page with an unapplied draft asks for confirmation.

Values are passed to Hyprland as they are; ARGVUS does not derive them from a percentage. Changing one surface's switch does not change the values.

## Canonical state and compatibility files

The logical preference is stored in `$XDG_CONFIG_HOME/argvus/config.json`. Global animation uses `effects.animations`. The global Blur switch is `effects.blur_global_enabled`, and the Blur values use the `effects.blur_*` keys listed above. Surface enable states and transparency values use keys such as `effects.blur_control-center_enabled` and `effects.transparency_control-center_value`. Transparency values are limited to `0–100`; each Blur value is limited to its own range, and `argvus-config` rejects writes outside it. Enable states remain distinct from missing overrides.

The former `effects.blur_global_value` percentage is no longer read. A profile that still contains it keeps the key on disk without effect, and Blur uses the defaults above until its values are applied.

```text
$XDG_CONFIG_HOME/argvus/config.json
```

`data/generated/effects/<active-theme>.conf` is the single projection for effects, written only by `argvus-config`; `effects-toggle.sh` is a thin delegate to `argvus-config effects` with no output of its own, and it is not a competing source of truth. Theme-specific defaults are used only when the canonical field is absent, and an explicit `false` is never treated as missing. Switching themes preserves canonical overrides and regenerates the affected projections.

Disabling a surface's Transparency or Blur switch affects only that surface; saved numeric values are retained for later re-enabling.

## Profiles

Theme export/import includes the active theme's transparency and blur values, together with the existing effect states. Inactive themes are not included in the profile. Generated Waybar, Quickshell and Hyprland runtime files are regenerated when the profile is applied.

All surface pages apply their drafts together with the `[ Apply ]` button. Control Center writes the canonical document through the effects helper, lets `argvus-config` project the effects tree, reloads affected consumers and reads the effective value back. Theme export/import includes the canonical appearance/effects scope; generated files are recreated rather than imported as authoritative state.
