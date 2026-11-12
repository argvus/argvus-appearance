---
title: 壁纸
description: 使用内置和自定义 ARGVUS 壁纸。
---
内置的 JPEG XL 壁纸由 `argvus-wallpapers` 安装在 `/usr/share/backgrounds/argvus/` 下。在 **控制中心 → 外观 → 壁纸** 中，它们按 `Abstract` 或 `Landscape` 组织，然后按 `Dark` 或 `Light` 分类。根目录 `argvus-dark.jxl` 和 `argvus-light.jxl` 文件显示在抽象备用组下。主题切换仅使用 `abstract/dark` 和 `abstract/light` 中的抽象文件；横向文件是可选的手动选择。按下 `SUPER + Y` 可直接打开此控制中心界面。第一个条目还支持来自 HOME 的自定义图片；选定的文件将成为用户的自定义壁纸状态。

第一个条目打开一个自定义图像的文件选择器。选定的自定义壁纸会与 /appearance/wallpaper_custom 一起存储为 `/appearance/wallpaper` 在规范配置中， `/appearance/wallpaper_custom` `argvus config` 将其投影到 Hyprland 壁纸配置中供会话使用。它将保持活动状态，直到主题或模式更改重新应用该主题的壁纸。导出当前主题以包含当前壁纸，并在导出的主题中保留它。`$XDG_CONFIG_HOME/argvus/.wallpaper-custom` 仅作为遗留迁移输入。

当主题被导出时，如果当前壁纸图像可读取，则会包含该图像。导入会安装该主题；应用它会激活其壁纸。参见 [导入和导出主题](/docs/components/argvus-themes/import-and-export/)。

面向用户的外观控制使用 Hyprland 辅助程序 `hypr-wallpaper-pick.sh`，该程序通过 `argvus config` 提交所选路径，而不是自行存储壁纸状态。请勿直接编辑生成的壁纸配置。
