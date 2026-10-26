-- Theme: {{ theme.id }}
-- Loaded by hyprland.lua via dofile()
return {
  border_active = "{{ @hypr_border_active | hypr }}",
  border_inactive = "{{ @hypr_border_inactive | hypr }}",
  groupbar_active = "{{ @hypr_border_active | hypr }}",
  groupbar_inactive = "{{ @hypr_groupbar_inactive | alpha(0.8) | hypr }}",
  shadow_color = {{ @hypr_shadow_color | argb_int }},
  shadow_color_inactive = {{ @hypr_shadow_color_inactive | argb_int }},
  rounding = {{ layout.hypr_rounding }},
  rounding_power = {{ layout.hypr_rounding_power }},
  gaps_in = {{ layout.hypr_gaps_in }},
  gaps_out = {{ layout.hypr_gaps_out }},
  border_size = 1,
}
