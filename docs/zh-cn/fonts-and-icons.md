---
title: 字体和图标
description: 配置 ARGVUS 使用的字体和图标主题。
---
`argvus-fonts` 会将捆绑字体安装在 `/usr/share/fonts/` 下；`argvus-icons` 会安装 ARGVUS 图标主题。`argvus-appearance` 和控制中心将这些资源连接到桌面主题。

## 主要字体

ARGVUS 默认的主要字体是 **IBM Plex Mono**，使用 `Regular` 样式。它是控制中心中显示的字体目标使用的默认字体家族。捆绑的 `argvus-fonts` 软件包提供 IBM Plex Mono 以及桌面使用的支持图标/终端字体家族。

打开 **控制中心 → 字体** 来配置各个目标：

- 任务栏；
- 遥测/系统信息；
- 控制面板；
- ARGVUS 系统界面；
- 应用程序；
- 终端；
- 浏览器。

默认大小因目标而异：任务栏、系统和终端使用 `13`；遥测和控制面板使用 `14`；应用程序使用 `12`；浏览器使用 `10`。这些默认设置可以在字体页面恢复。

## 图标主题

活动图标主题以规范形式存储为 `appearance.icon_theme` 在 `config.json` 中。空值（默认值）选择活动主题模式的 ARGVUS 图标主题：`Argvus Dark Icons` 用于深色主题，`Argvus Light Icons` 用于浅色主题，这两者都由 `argvus-icons` 安装。

`sh/icon-switch.sh` 解析有效主题并将其应用于每个使用者：

- GNOME 设置：`org.gnome.desktop.interface icon-theme`；
- GTK 3 和 GTK 4：`gtk-icon-theme-name` 在 ARGVUS 和本地 `settings.ini` 文件中；
- Qt：`icon_theme` 在管理的 `qt6ct.conf` 中，并在由 ARGVUS 生成时在本地 `qt6ct.conf` 中。

主题在 `/usr/share/icons`、`$XDG_DATA_HOME/icons` 和 `~/.icons` 中查找。未安装的已配置主题，或包含 `/` 或为 `..` 的值，将回退到相同模式的默认设置并记录一条消息，因此桌面永远不会指向缺失的主题。主题或模式切换时，如果存在，会使用导出主题配置文件中的图标选择，否则将恢复打包模式的默认设置。导出主题以在切换时保留自定义图标选择。

在控制中心使用字体控制。在`config.json`中，字体偏好是规范的，在`fonts.targets.<target>`中用于字体系列、样式和大小，加上`fonts.rendering`用于抗锯齿、提示、子像素顺序和DPI。控制中心通过`argvus-config`保持它们；它本身不写消费者文件。`argvus-config` 然后投射`data/generated/fonts.conf`，并重写`data/waybar/argvus-taskbar.css`和`data/waybar/argvus-widget-telemetry.css`中的定界字体块，因此这些块外的字体编辑在更改字体后仍然存在。终端和GTK的fontconfig规则仍然是本地适配器目标。该软件包在安装过程中运行字体缓存更新。

任务栏模块生成在发布之前会验证生成的 JSONC。实用程序模块列表根据已启用的偏好重新构建，包括仅在悬停模式下的抽屉展开器。工作区图标模式会同时渲染 `{windows}` 和 `{name}`。系统托盘可见性仅影响后台应用程序图标。

启用可选模块并由任务栏模板定义时，实用程序组投影仪会保留 custom/ai。其 nf-md-robot 图标（U+F06A9）用于打开共享 AI 代理菜单；可用性仍由模块控制，即使所有其他实用程序图标被禁用时亦然。

AI 图标的可见性由 /taskbar/icons/ai_agents_enabled 控制（默认值为 true），在控制中心 > 外观 > 任务栏 > 图标 > 可选模块 > AI 代理下可见。投影仪在每次应用时都会尊重禁用状态，并且在仅启用 AI 代理时仍保留实用程序组。

任务栏投影器在 `/taskbar/icons/update_status_enabled` 为 true 时，会将更新状态放置在实用程序组和网络/性能组之间的单独组中。它还会用模块定义升级较早生成的配置。

辅助程序是 `argvus window-mode-menu`；`argvus window-mode-menu --status` 输出 Waybar JSON。它由主 `argvus` 软件包提供。现有的自定义任务栏副本会被保留：从打包的模板中添加 `custom/window-mode` 模块定义和组条目以选择启用，或者使用控制中心。外观投影器在定义存在时会保留该模块，即使其他实用程序图标被禁用。

`window-bar` 和 `window-controls` 主题使用者的颜色来自 bg、fg 和 accent。标题栏颜色通过 `argvus windows decorations` 重新加载；窗口栏遵循其生成的样式表。平铺/浮动与固定/间隔的外观几何独立。
