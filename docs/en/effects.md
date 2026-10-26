---
title: Effects
description: Configure animations, the global Hyprland blur and per-surface transparency.
---

**Control Center → Hyprland** contains **Animations** and **Blur**. Transparency enable switches are per-surface settings in their respective Appearance pages.

Surface switches are independent. The Control Center Configuration page has its own Transparency value and Blur enable switch; its blur uses the global Blur values.

The Control Center is launched through Foot with a dedicated generated profile at `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`. With Foot 1.28, transparency is projected to `[colors-dark] alpha` and the surface Blur switch to `[colors-dark] blur`; the normal Foot configuration and ARGVUS terminal remain independent.

## Animations and Effects switches

There are two independent master switches, both applied to `hyprland.lua` through the canonical `/effects` settings:

- **Animations** (`/effects/animations`) controls everything that moves: workspace, window, fade, border and layer animations.
- **Effects** is a shortcut for blur (`/effects/blur_global_enabled`) and the transparency of Terminal, Launcher, Widget Telemetry, Control Panel and Taskbar (`/effects/transparency_<surface>_enabled`, which also drives the window shadows). Turning it on or off writes all of them (and the Control Center transparency too). Each surface keeps its own transparency page, so Effects reads as **on when at least one of them is on** and as off only when every one is off.

Use `argvus effects-toggle animations status|enable|disable|toggle` and `argvus effects-toggle effects status|enable|disable|toggle`. The Control Panel Appearance card shows one switch for each. Turning a master switch off keeps every fine setting of the **Animations** and **Blur** pages (speeds, curves, per-leaf switches, blur size and passes), so turning it on again restores the same look. `effects status` prints `enabled` when blur or at least one of those transparency surfaces is enabled. Turning a surface's transparency off makes the whole Waybar surface opaque: besides the background, the translucent borders of the taskbar and the Widget Telemetry become the solid color they show over the theme background. Every effect is enabled by default on a fresh install, including on virtual machines and low-power sessions; only an explicit setting turns one off.

## All effects at once

`argvus effects-toggle` without a component acts on animations, blur and transparency together: `status` prints `enabled` only when all three are enabled, `enable` and `disable` switch all three, and `toggle` switches everything off when `status` is `enabled` and on otherwise. **SUPER + F6** runs this toggle. To act on a single group, name it: `argvus effects-toggle animations|effects|blur|transparency status|enable|disable|toggle`. The **Animations** page of the Control Center uses the per-component form, so its **Enable** switch still changes animations only.

## Transparency

Each surface has its own **Transparency** submenu with an enable switch and value.

The **Appearance → Launchers** page controls the official Rofi-based launcher and picker flows: the main launcher, emoji picker, calculator, clipboard picker, cheatsheets and Rofi removable-device menus. Its Transparency value is the final background alpha, so `50` means an effective background opacity of approximately `0.50`; text, icons and selected rows remain opaque. With Transparency turned off, the launcher uses the active theme's own background color, fully opaque. Its Blur switch opts the `rofi` layer into the global Blur settings.

Each value ranges from `0%` (opaque) to `100%` (fully transparent). Use `+` and `-` in 5% steps, then select **Apply** on the surface page. Leaving the page discards an un-applied draft.

Use `↑` and `↓` to move between **Enable** and **Value**. On the **Value** row, `+` and `-` adjust the draft without changing focus. Press `Tab` to open **Actions**, then activate **[ Apply ]**; `Esc` returns to the parent surface page.

## Animations

Open **Control Center → Hyprland → Animations**. The page has an **Enable** switch and an **Options** list with **Custom curves** and five categories. Each category lists its animations, and each animation has its own page with **Style**, **Speed**, **Curve** and, for window opening and closing, **Pop-in percentage**. Animations that Hyprland can switch off also have an **Enable** row.

Every value on these pages belongs to one draft shared by the whole Animations tree. Nothing is written until **[ Apply ]** is selected at the bottom of any of them. Moving between the pages keeps the draft; leaving the Animations page with an unapplied draft asks for confirmation. Apply writes the changed values in one call and reloads Hyprland. The **Enable** switch at the top is the global animation state (`effects.animations`): when it is off, every animation is disabled, whatever its own switch says.

Controls: `↑/↓` moves between rows; `←/→` (or `+/-`) changes the selected value and cycles **Style** and **Curve**; `Enter` types an exact **Speed**, **Pop-in percentage** or curve parameter (out-of-range values are refused), and cycles **Style** and **Curve** forward.

### Categories and animations

| Category | Animation | Key (`effects.animation_<key>_*`) | Style (default) | Speed | Enable |
|---|---|---|---|---|---|
| Windows | Opening of windows | `opening` | `popin`, pop-in 87% | 4.1 | — |
| Windows | Closing of windows | `closing` | `popin`, pop-in 87% | 1.49 | — |
| Windows | Moving windows | `moving` | — | 4.79 | yes |
| Workspaces | Switching workspaces | `switching` | `fade` | 1.94 | — |
| Workspaces | Workspace entrance | `workspace_in` | `fade` | 1.21 | — |
| Workspaces | Workspace exit | `workspace_out` | `fade` | 1.94 | — |
| Workspaces | Special workspaces | `special_workspace` | `slide` | 5 | — |
| Layers & popups | Layer surfaces | `layers` | — | 3.81 | yes |
| Layers & popups | Layer entrance | `layers_in` | `fade` | 4 | — |
| Layers & popups | Layer exit | `layers_out` | `fade` | 1.5 | — |
| Layers & popups | Fade | `fade` | — | 3.03 | yes |
| Layers & popups | Fade in | `fade_in` | — | 1.73 | yes |
| Layers & popups | Fade out | `fade_out` | — | 1.46 | yes |
| Borders & effects | Border color | `border` | — | 5.39 | yes |
| Borders & effects | Border gradient angle | `border_angle` | — | 5 | yes |
| Other animations | Zoom factor | `zoom` | — | 7 | yes |
| Other animations | Monitor added | `monitor_added` | — | 5 | yes |

The defaults of the leaves that Hyprland 0.56.2 ships in its stock configuration (every row except Special workspaces, Border gradient angle and Monitor added) are the stock speeds, styles and curves. Those three keep ARGVUS defaults, because the stock configuration does not define them.

Each leaf offers only the styles Hyprland 0.56.2 accepts for it. Window opening and closing offer `slide`, `popin`, `slidefade`, `slidevert`, `slidefadevert` and `gnomed`. Layer entrance and exit offer `slide`, `popin`, `fade`, `slidefade`, `slidevert` and `slidefadevert`. Workspace leaves (switching, entrance, exit and special workspaces) offer `slide`, `fade`, `slidefade`, `slidevert` and `slidefadevert`, without `popin` or `gnomed`. A stored style outside its leaf's list is ignored and the leaf uses its default. Every animation starts with the `default` curve. A page only offers the rows its animation supports. The stored keys are `effects.animation_<key>_speed`, `_curve`, `_style` (where offered), `_popin` (window opening and closing) and `_enabled` (where offered).

### Curves

| Curve | Behavior | Parameters (key → default) |
|---|---|---|
| `default` | The curve Hyprland 0.56.2 ships for that animation (for example `easeOutQuint`, `almostLinear`, `quick`, `linear` or the `easy` spring). Animations without a stock curve use ARGVUS's built-in Bézier. | Fixed. |
| `bezier` | Smooth motion that accelerates and decelerates, shaped by two control points. | `bezier_x1` 0.23, `bezier_y1` 1, `bezier_x2` 0.32, `bezier_y2` 1 (x 0–1, y −2–3) |
| `spring` | Physical motion with mass, stiffness and dampening; it can overshoot for an elastic effect. | `spring_mass` 1, `spring_stiffness` 238.1191, `spring_dampening` 24.21279333 |
| `linear` | Constant speed for the whole animation, from `(0, 0)` to `(1, 1)`. | Fixed. |
| `ease_out` | Fast at the start and smooth at the end, from `(0, 0)` to `(0.58, 1)`. | Fixed. |

Under **Custom curves**, each curve has its own page. Bézier edits its four control points, Spring edits mass, stiffness and dampening, and Linear and Ease-out show their fixed points. The Bézier and Spring values apply to every animation that selects that curve.

Ranges and steps: **Speed** 1–10 with decimals (step 0.1, the stock speeds are decimal); **Pop-in percentage** 1–100 in whole numbers (step 5, stock 87); Bézier points as above (step 0.05); Spring mass 0.5–10 (step 0.1), stiffness 0.5–2000 (step 10) and dampening 0.5–200 (step 1).

Not offered: Hyprland 0.56.2 has no separate animation for resizing windows, for popups, or for the shadow and glow gradient angles, so the page does not show rows for them.

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

The logical preference is stored in `$XDG_CONFIG_HOME/argvus/config.json`. Global animation uses `effects.animations`; the Animations values use the `effects.animation_*` keys described above. The global Blur switch is `effects.blur_global_enabled`, and the Blur values use the `effects.blur_*` keys listed above. Surface enable states and transparency values use keys such as `effects.blur_control-center_enabled` and `effects.transparency_control-center_value`. Transparency values are limited to `0–100`; each Blur value is limited to its own range, and `argvus-config` rejects writes outside it. Enable states remain distinct from missing overrides.

The former `effects.blur_global_value` percentage is no longer read. A profile that still contains it keeps the key on disk without effect, and Blur uses the defaults above until its values are applied.

```text
$XDG_CONFIG_HOME/argvus/config.json
```

`data/generated/effects/<active-theme>.conf` is the single projection for effects, written only by `argvus config`; `argvus effects-toggle` is a thin delegate to `argvus config effects` with no output of its own, and it is not a competing source of truth. Theme-specific defaults are used only when the canonical field is absent, and an explicit `false` is never treated as missing. Switching themes preserves canonical overrides and regenerates the affected projections.

Disabling a surface's Transparency or Blur switch affects only that surface; saved numeric values are retained for later re-enabling.

## Profiles

Theme export/import includes the active theme's transparency and blur values, together with the existing effect states. Inactive themes are not included in the profile. Generated Waybar, Quickshell and Hyprland runtime files are regenerated when the profile is applied.

All surface pages apply their drafts together with the `[ Apply ]` button. Control Center writes the canonical document through the effects helper, lets `argvus-config` project the effects tree, reloads affected consumers and reads the effective value back. Theme export/import includes the canonical appearance/effects scope; generated files are recreated rather than imported as authoritative state.
