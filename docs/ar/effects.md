---
title: Effects
description: قم بتكوين الرسوم المتحركة وطمس Hyprland العالمي والشفافية لكل سطح.
---

**مركز التحكم → Hyprland** يحتوي على **الرسوم المتحركة** و**التمويه** و**الحدود**، والتي تتحكم صفحة **الظل** الخاصة بها في ظل النافذة. تعد مفاتيح تمكين الشفافية بمثابة إعدادات لكل سطح في صفحات المظهر الخاصة بها.

المفاتيح السطحية مستقلة. تحتوي صفحة تكوين مركز التحكم على قيمة الشفافية الخاصة بها ومفتاح تمكين Blur؛ يستخدم التمويه قيم Blur العالمية.

## 

There are two independent master switches, both applied to 

```text
$XDG_CONFIG_HOME/argvus/config.json
```

 through the canonical `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini` settings:

- **Animations** (

) controls everything that moves: workspace, window, fade, border and layer animations.
- **Effects** is a shortcut for blur (

) and the transparency of Terminal, Launcher, Widget Telemetry, Control Panel and Taskbar (`[colors-dark] alpha` /effects/transparency_<surface>_enabled  /effects/blur_global_enabled  /effects/animations  /effects  hyprland.lua  `[colors-dark] blur` ). Turning it on or off writes all of them (and the Control Center transparency too). Each surface keeps its own transparency page, so Effects reads as **on when at least one of them is on** and as off only when every one is off.

استخدم  `hyprland.lua`  `/effects`  `/effects/animations`  `/effects/blur_global_enabled`  `/effects/transparency_<surface>_enabled` `argvus effects-toggle animations status|enable|disable|toggle` و`argvus effects-toggle effects status|enable|disable|toggle`. تعرض بطاقة مظهر لوحة التحكم مفتاحًا واحدًا لكل منها. يؤدي إيقاف تشغيل المفتاح الرئيسي إلى الحفاظ على كل الإعدادات الدقيقة لصفحات **الرسوم المتحركة** و**التمويه** (السرعات والمنحنيات ومفاتيح التبديل لكل ورقة وحجم التمويه والتمريرات)، لذا فإن تشغيله مرة أخرى يؤدي إلى استعادة المظهر نفسه. يقوم `effects status` بطباعة `enabled` عند التمويه أو عندتم تمكين واحد على الأقل من أسطح الشفافية هذه. يؤدي إيقاف شفافية السطح إلى جعل سطح Waybar بأكمله معتمًا: إلى جانب الخلفية، تصبح الحدود الشفافة لشريط المهام وقياس عناصر واجهة المستخدم عن بُعد هي اللون الصلب الذي تظهره على خلفية السمة. يتم تمكين كل تأثير افتراضيًا عند التثبيت الجديد، بما في ذلك الأجهزة الافتراضية and low-power sessions; only an explicit setting turns one off.

## 

`argvus effects-toggle`                    :ﺎًﻌﻣ ﺔﻴﻓﺎﻔﺸﻟﺍﻭ ﺶﻳﻮﺸﺘﻟﺍﻭ ﺔﻛﺮﺤﺘﻤﻟﺍ ﻡﻮﺳﺮﻟﺍ ﻰﻠﻋ ﻞﻤﻌﻳ ﻥّﻮﻜﻣ ﻥﻭﺪﺑ`status` prints `enabled`                                            ،ﻢﻬﻌﻴﻤﺟ ﺔﺛﻼ﻿ﺜﻟﺍ ﻦﻴﻜﻤﺗ ﻢﺘﻳ ﺎﻣﺪﻨﻋ ﻂﻘﻓ`enable` and `disable`                                                           ﻭ ،ﺎًﻌﻴﻤﺟ ﺔﺛﻼ﻿ﺜﻟﺍ ﻝّﺪﺑ`toggle`                                                             ﺎﻣﺪﻨﻋ ءﻲﺷ ﻞﻛ ﺊﻔﻄﻳ`status` is `enabled` :ﺎﻬّﻤﺳ ،ﺓﺪﺣﺍﻭ ﺔﻋﻮﻤﺠﻣ ﻰﻠﻋ ﻑﺮﺼﺘﻠﻟ .ﻞﻳﺪﺒﺘﻟﺍ ﺍﺬﻫ ﻞّﻐﺸﻳ **SUPER + F6** .ﻚﻟﺫ ﻑﻼ﻿ﺧ ﻰﻠﻋﻭ`argvus effects-toggle animations|effects|blur|transparency status|enable|disable|toggle`.ﻂﻘﻓ ﺔﻛﺮﺤﺘﻤﻟﺍ ﻡﻮﺳﺮﻟﺍ ﺮﻴﻐﻳ **ﻦﻴﻜﻤﺗ** ﺡﺎﺘﻔﻣ ﻞﻈﻳ ﻚﻟﺬﻟ ،ﻥﻮﻜﻣ ﻞﻜﺑ ﺹﺎﺨﻟﺍ ﺝﺫﻮﻤﻨﻟﺍ ﻢﻜﺤ

## Transparency



The **Appearance → Launchers** page controls the official Rofi-based launcher and picker flows: the main launcher, emoji picker, calculator, clipboard picker, cheatsheets and Rofi removable-device menus. Its Transparency value is the final background alpha, so 

 means an effective background opacity of approximately `50`; text, icons and selected rows remain opaque. With Transparency turned off, the launcher uses the active theme's own background color, fully opaque. Its Blur switch opts the `0.50` Esc  Tab  -  +  ↓  ↑  -  +  100%  0%  `rofi`  layer into the global Blur settings.





## Animations

Open **Control Center → Hyprland → Animations**. The page has an **Enable** switch and an **Options** list with **Custom curves** and five categories. Each category lists its animations, and each animation has its own page with **Style**, **Speed**, **Curve** and, for window opening and closing, **Pop-in percentage**. Animations that Hyprland can switch offلديك أيضًا صف **تمكين**.تنتمي كل قيمة في هذه الصفحات إلى مسودة واحدة مشتركة بين شجرة الرسوم المتحركة بأكملها. لا يتم كتابة أي شيء حتى يتم تحديد **[ Apply ]** أسفل أي منها. التنقل بين الصفحات يحافظ على المسودة؛ ترك صفحة الرسوم المتحركة مع عدم تطبيقها draft asks for confirmation. Apply writes the changed values in one call and reloads Hyprland. The **Enable** switch at the top is the global animation state ( `0%`  `100%`  `+`  `-`  `↑`  `↓`  `+`  `-`  `Tab`  `Esc` `effects.animations`): when it is off, every animation is disabled, whatever its own switchيقول.عناصر التحكم: `↑/↓` يتحرك بين الصفوف؛ يقوم `←/→` (أو `+/-`) بتغيير القيمة والدورات المحددة **النمط** و**المنحنى**؛ يقوم `Enter` بكتابة **Speed** أو **نسبة مئوية منبثقة** أو معلمة منحنى (يتم رفض القيم خارج النطاق)، ودورات **Style** و **Curve** للأمام.

### الفئات والرسوم المتحركة| Category | Animation | Key (`effects.animation_<key>_*`) | Style (default) | Speed | Enable |
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



تقدم كل ورقة فقط الأنماط التي يقبلها Hyprland 0.56.2 لها. عرض فتح وإغلاق النوافذ `slide`، `popin`، `slidefade`، `slidevert`، `slidefadevert` و`gnomed`. عرض الدخول والخروج من طبقة `slide`، `popin`، `fade`، `slidefade`، `slidevert` و`slidefadevert`. توفر أوراق مساحة العمل (التبديل والدخول والخروج ومساحات العمل الخاصة) `slide` و`fade` و`slidefade` و`slidevert` و`slidefadevert`، بدون `popin` أو `gnomed`. يتم تجاهل النمط المخزن خارج قائمة أوراقه وتستخدم الورقة إعداداتها الافتراضية. تبدأ كل الرسوم المتحركة بمنحنى `default`. تقدم الصفحة فقط الصفوف التي تدعمها الرسوم المتحركة الخاصة بها. المفاتيح المخزنة هي `effects.animation_<key>_speed`، `_curve`، `_style`(حيثما يتم عرضه)، `_popin` (فتح وإغلاق النافذة) و`_enabled` (حيثما يتم عرضه).

### منحنيات

| منحنى | السلوك | المعلمات (المفتاح → الافتراضي) |
|---|---|---|
| `default` | يأتي منحنى Hyprland 0.56.2 لتلك الرسوم المتحركة (على سبيل المثال `easeOutQuint` أو `almostLinear` أو `quick` أو `linear` أو زنبرك `easy`). الرسوم المتحركة التي لا تحتوي على منحنى الأسهم تستخدم Bézier المدمج في ARGVUS. | مُثَبَّت. |
| `bezier` | حركة سلسة تتسارع وتتباطأ، تتشكل من خلال نقطتي تحكم. | `bezier_x1` 0.23، `bezier_y1` 1، `bezier_x2` 0.32، `bezier_y2` 1 (x 0–1، y −2–3) || `spring` | الحركة الجسدية مع الكتلة والتصلب والتثبيط. يمكن أن تتجاوز الحدود للحصول على تأثير مرن. | `spring_mass` 1، `spring_stiffness` 238.1191، `spring_dampening` 24.21279333 || `linear`                                        ﻦﻣ ،ﺔﻛﺮﺤﺘﻤﻟﺍ ﻡﻮﺳﺮﻟﺍ ﻝﺍﻮﻃ ﺔﺘﺑﺎﺛ ﺔﻋﺮﺳ | `(0, 0)` to `(1, 1)`. | Fixed. |
| `ease_out`                                           ﻦﻣ ،ﺔﻳﺎﻬﻨﻟﺍ ﻲﻓ ﺲﻠﺳﻭ ﺔﻳﺍﺪﺒﻟﺍ ﻲﻓ ﻊﻳﺮﺳ`(0, 0)` to `(0.58, 1)`. | Fixed. |







## Blur

Hyprland:

| Row | Config key | Default | Range |  `decoration:blur` `←/→` step |
|---|---|---|---|---|
| Size | `effects.blur_size` | `6` | 1–64 | 1 |
| Passes | `effects.blur_passes` | `2` | 1–8 | 1 |
| Brightness | `effects.blur_brightness` | `1` | 0–2 | 0.05 |
| Noise | `effects.blur_noise` | `0.00` | 0–1 | 0.01 |
| Contrast | `effects.blur_contrast` | `0.900000` | 0–2 | 0.05 |
| Vibrancy | `effects.blur_vibrancy` | `0.100000` | 0–1 | 0.01 |
| Vibrancy darkness | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0.01 |

Use 

 to move, `↑/↓` (or `←/→`) to change the selected value by its step, and `+/-` `Enter`  to type an exact value; values outside the range are refused. Nothing is written while you edit: the switch and the values stay in the draft until **[ Apply ]** at the bottom of the page is selected. Apply writes every changed value in one call, and reloads Hyprland after it. Leaving the page with an unapplied draft asks for confirmation.

.ﻢﻴﻘﻟﺍ ﺮﻴﻐﻳ ﻻ﻿ ﺪﺣﺍﻭ ﺢﻄﺳ ﺡﺎﺘﻔﻣ ﺮﻴﻴﻐﺗ .ﺔﻳﻮﺌﻤﻟﺍ ﺔﺒﺴﻨﻟﺍ ﻦﻣ ﺎﻬﺼﻠﺨﺘﺴ

## Shadow

ظل النافذة هو إعداد Hyprland عالمي، ضمن **Control Center → Hyprland → Borders → Shadow**. إنها مستقلة عن الشفافية والتمويه: فهي متوقفة عن التشغيل بشكل افتراضي، وتشغيل أو إيقاف شفافية السطح لا يغيرها.

| صف | مفتاح التكوين | الافتراضي | النطاق | خطوة `←/→` |
|---|---|---|---|---|
| تمكين | `effects.shadow_enabled` | `false` | — | — |
| شارب | `effects.shadow_sharp` | `false` | — | — |
| اللون | `effects.shadow_color` | فارغ (يتبع اللهجة) | فارغ أو `RRGGBBAA` | — |
| النطاق | `effects.shadow_range` | `6` | 0–100 | 1 |
| تقديم القوة | `effects.shadow_render_power` | `6` | 1–10 | 1 |
| إزاحة X | `effects.shadow_offset_x` | `0` | −100 إلى 100 | 1 || Offset Y | `effects.shadow_offset_y` | `0` | −100 to 100 | 1 |
| Scale | `effects.shadow_scale` | `1.00` | 0–1 | 0.05 |

يتبع اللون الفارغ تمييز السمة النشطة بألفا `99`، وبالتالي فإن التمييز الأزرق الافتراضي يعطي `3590bd99`. اكتب ثمانية أرقام سداسية عشرية (`RRGGBBAA`) لإصلاح اللون، أو اترك المطالبة فارغة لمتابعة التمييز مرة أخرى. تتم قراءة اللون عند تكوين Hyprland loads, so after a theme or accent change it takes the new accent on the next configuration reload.

.ﺍًﺪﻴﻛﺄﺗ ﺐﻠﻄﻳ ﺔﻘﺒﻄﻣ ﺮﻴﻏ ﺓﺩﻮﺴﻣ ﺩﻮﺟﻭ ﻊﻣ ﺔﺤﻔﺼﻟﺍ ﺓﺭﺩﺎﻐﻣﻭ ،**[ﻖﻴﺒﻄﺗ]** ﺭﺎﻴﺘﺧﺍ ﻢﺘﻳ ﻰﺘ

##                                       ﺔﻴﺟﺫﻮﻤﻨﻟﺍ ﻖﻓﺍﻮﺘﻠﻟ ﺔﻴﻠﺑﺎﻘﻟﺍﻭ ﺔﻟﺎﺤﻟﺍ ﺕﺎﻔﻠﻣ

 effects.blur_global_value  argvus-config  0–100  effects.transparency_control-center_value  effects.blur_control-center_enabled  effects.blur_*  effects.blur_global_enabled  effects.animation_*  effects.animations  `$XDG_CONFIG_HOME/argvus/config.json`  `effects.animations`  `effects.animation_*`  `effects.blur_global_enabled`  `effects.blur_*`  `effects.blur_control-center_enabled`  `effects.transparency_control-center_value`  `0–100`  `argvus-config`  `effects.blur_global_value` `data/generated/effects/<active-theme>.conf`                                                    ﻂﻘﻓ ﻪﺒﺘﻛ ،ﺕﺍﺮﻴﺛﺄﺘﻟﺍ ﺽﺮﻋ ﻮﻫ`argvus config`; `argvus effects-toggle`                                                                   ﻰﻟﺇ ﻥﻮﺑﻭﺪﻨﻣ`argvus config effects`ﻦﻣ ﺢﻄﺳ ﻞﻜﺑ ﺔﺻﺎﺨﻟﺍ ﻢﻴﻘﻟﺍ ﻚﻟﺫ ﻲﻓ ﺎﻤﺑ ،ﺔﻄﺸﻨﻟﺍ ﺔﻤﺴﻠﻟ ﺭَّﺪﺼُﻤﻟﺍ ﻱﺮﺼﺒﻟﺍ ﻲﺼﺨﺸﻟﺍ ﻒﻠﻤﻟﺍ ﻖﻴ`effects.conf`.ﺮﺧﺁ ﻊﺿﻭ ﻭﺃ ﻯﺮﺧﺃ ﺔﻤﺳ ﻞﻳﺪﺒﺗ ﺪﻌﺑ ﻢﻴﻘﻟﺍ ﻩﺬﻫ ﻰﻘﺒﺗ ﻥﺃ ﺪﻳﺮﺗ ﺖﻨﻛ ﺍﺫﺇ ﺕﺍﺮﻴﺛﺄﺘﻟﺍ ﺮﻴﻴﻐﺗ 

.ﺎًﻘﺣﻻ﻿ ﻞﻴﻌﻔﺘﻟﺍ ﺓﺩﺎﻋﻹ﻿ ﺔﻇﻮﻔﺤﻤﻟﺍ ﺔﻴﻤﻗﺮﻟﺍ ﻢﻴﻘﻟﺎﺑ ﻅﺎﻔﺘﺣﻻ﻿ﺍ ﻢﺘﻳ ؛ﺢﻄﺴﻟ

## Profiles

.ﻢﻴﺜﻟﺍ ﻖﻴﺒﻄﺗ ﺪﻨﻋ Hyprlandﻭ Quickshellﻭ Waybar ـﻟ ﻞﻴﻐﺸﺘﻟﺍ ﺖﻗﻭ

.ﺔﻗﻮﺛﻮﻣ ﺔﻟﺎﺤﻛ ﺎﻫﺩﺍﺮﻴﺘﺳﺍ ﻦﻣ ًﻻ﻿ﺪﺑ ﺓﺪﻟ

## ﻞﻴﻠﻟﺍ ءﻮﺿ

**SUPER + Shift + B** keeps the brightness selector and adds a separate Night Light toggle with effective state/temperature. It calls  argvus-config  `[ Apply ]`  `argvus-config` `argvus config display night-light status|toggle`. Night Light requires Hyprland and a responding Hyprsunset >= 0.4.0, independently of brightness support. The range is 1000–20000 K; configuration is under **Desktop .ﺎًﺌﻴﺷ ﺮﻴﻐﻳ ﻻ﻿ ﺔﻤﺋﺎﻘﻟﺍ ءﺎﻐﻟﺇ .ﺔﻟﻭﺪﺠﻟﺍ ﻊﻣ ﻲﻟﺎﺘﻟﺍ ﻝﺎﻘﺘﻧﻻ﻿ﺍ ﻰﺘﺣ ﺖﻗﺆ
