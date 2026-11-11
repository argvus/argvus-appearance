---
title: Fonts and icons
description: ARGVUS ۔ﮟﯾﺩ ﺐﯿﺗﺮﺗ ﻮﮐ ﺰﻤﯿﮭﺗ ﻦﮑﺋﺁ ﺭﻭﺍ ﺲﭩﻧﻮﻓ ﮯﻟﺍﻭ ﮯﻧﻮﮨ ﻝﺎﻤﻌﺘﺳﺍ ﮟﯿﻣ
---

`argvus-fonts`                                      ﮯﮨ ﺎﺗﺮﮐ ﻝﺎﭩﺴﻧﺍ ﮟﯿﻣ ﻞﯾﺫ ﻮﮐ ﺲﭩﻧﺎﻓ ﮦﺪﺷ ﻝﮉﻨﺑ`/usr/share/fonts/`; `argvus-icons`ARGVUS ۔ﮯﮨ ﺎﺗﺮﮐ ﻝﺎﭩﺴﻧﺍ ﻮﮐ ﺰﻤﯿﮭﺗ ﻦﮑﯿﺋﺁ`argvus-appearance`                      ۔ﮯﮨ ﺎﺗﮌﻮﺟ ﮯﺳ ﻢﯿﮭﺗ ﭖﺎﭨ ﮏﺴﯾﮈ ﻮﮐ ﮞﻮﺛﺎﺛﺍ ﻥﺍ ﺮﭩﻨﯿﺳ ﻝﻭﺮﭩﻨﮐ ﺭﻭﺍ

##                                                                       ﭧﻧﻮﻓ ﻢﮨﺍ

The ARGVUS default primary font is **IBM Plex Mono**, with the  `Regular` `argvus-fonts` style. It is the default family used by the font targets exposed in Control Center. The bundled `13` package provides IBM Plex Mono and the supporting icon/terminal families used by the desktop.

:ﮯﮑﺳ ﺎﺟ ﺎﯾﺩ ﺐﯿﺗﺮﺗ ﻮﮐ ﻑﺍﺪﮨﺍ ﯼﺩﺍﺮﻔﻧﺍ ﮧﮐﺎﺗ **ﺲﭩﻧﻮﻓ → ﺮﭩﻨﯿﺳ ﻝﻭﺮﭩﻨ

- taskbar;
- telemetry/system information;
- Control Panel;
- ARGVUS system interface;
- applications;
- terminal;
- browser.

The default sizes are target-specific: taskbar, system and terminal use `14`; telemetry and Control Panel use `12`; applications use `10`; and browser uses argvus-appearance. These defaults can be restored from the Fonts page.

## ﻢﯿﮭﺗ ﻦﮑﯿﺋﺁ

                           ﮯﮨ ﯽﺗﺎﺟ ﯽﮐ ﻅﻮﻔﺤﻣ ﺡﺮﻃ ﺱﺍ ﺮﭘ ﺭﻮﻃ ﯽﻤﺳﺭ ﻢﯿﮭﺗ ﻦﮑﯿﺋﺁ ﻝﺎﻌﻓ`appearance.icon_theme` in `config.json` :ﮯﮨ ﯽﺗﺮﮐ ﺐﺨﺘﻨﻣ ﻮﮐ ﻢﯿﮭﺗ ﻦﮑﯿﺋﺁ ARGVUS ﮯﮐ ﮈﻮﻣ ﮯﮐ ﻢﯿﮭﺗ ﻮﯿﭩﮑﯾﺍ (ﭧﻟﺎﻔﯾﮈ) ﺖﻤﯿﻗ ﯽﻟﺎﺧ `Argvus Dark Icons`                                                       ﺭﻭﺍ ﮯﯿﻟ ﮯﮐ ﺕﺎﻋﻮﺿﻮﻣ ﮮﺮﮩﮔ`Argvus Light Icons`                                          ﮯﺌﮔ ﮯﯿﮐ ﺐﺼﻧ ﮞﻮﻧﻭﺩ ،ﮯﯿﻟ ﮯﮐ ﺰﻤﯿﮭﺗ ﮯﮑﻠﮨ`argvus-icons`.

`sh/icon-switch.sh` ﮯﮨ ﺎﺗﺮﮐ ﻮﮔﻻ﻿ ﺮﭘ ﻑﺭﺎﺻ ﺮﮨ ﮯﺳﺍ ﺭﻭﺍ ﮯﮨ ﺎﺗﺮﮐ ﻞﺣ ﻮﮐ ﻢﯿﮭﺗ ﺮﺛﺆﻣ:

- GNOME ﺕﺎﺒﯿﺗﺮﺗ ﯽﮐ: `org.gnome.desktop.interface icon-theme`;
- GTK 3 ﺭﻭﺍ GTK 4: `gtk-icon-theme-name`                                              ﮟﯿﻣ ﯽﻣﺎﻘﻣ ﺭﻭﺍ ﺲﯾﺍ ﻮﯾ ﯼﻭ ﯽﺟ ﺭﺁ ﯼﺍ`settings.ini` files;
- Qt: `icon_theme` ﻢﻈﻨﻣ `qt6ct.conf` ﯽﺗﺭﺪﻗ ﺭﻭﺍ ،ﮟﯿﻣ `qt6ct.conf` 








۔ﮞﻮﮨ ﻝﺎﻌﻓ ﺮﯿﻏ ﺰﻨﮑﯿﺋﺁ ﯽﭩﻠﯿﭨﻮﯾ ﺮﮕﯾﺩ ﻡﺎﻤﺗ ﺐﺟ ﺖﻗﻭ ﺱﺍ ﻝﻮﻤﺸﺑ ،ﮯﮨ ﯽﺗ


AI ﻮﮐ ﺶﺋﺎﻤﻧ ﯽﮐ ﻦﮑﯿﺋﺁ /taskbar/icons/ai_agents_enabled (ﭧﻟﺎﻔﯾﮈ true) ﻮﺟ ،ﮯﮨ ﺎﺗﺎ





The  `/usr/share/icons`  `$XDG_DATA_HOME/icons`  `~/.icons`  `/`  `..`  `config.json`  `fonts.targets.<target>`  `fonts.rendering`  data/waybar/argvus-taskbar.css  data/generated/fonts.conf  `argvus-config`  `argvus-config`  `data/generated/fonts.conf`  `data/waybar/argvus-taskbar.css`  `data/waybar/argvus-widget-telemetry.css`  `{windows}`  `{name}`  `/taskbar/icons/update_status_enabled`  `argvus window-mode-menu`  `argvus window-mode-menu --status` `argvus`  `custom/window-mode`  `window-bar` and `window-controls` theme consumers derive their colors from bg, fg and accent. Title-bar colors reload through `argvus windows decorations`; the window bar observes its generated stylesheet. Tile/Floating is independent of Sticky/Spaced appearance geometry.
