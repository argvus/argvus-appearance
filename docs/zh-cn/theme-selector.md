---
title: 可视化主题选择器
---

使用 `argvus theme-selector`、不带参数的 `argvus theme-switch` 或 `SUPER + Shift + T` 打开。独立 GTK 浮层在当前显示器显示中央预览和相邻卡片。支持搜索和全部/深色/浅色筛选。使用方向键、滚轮或侧边卡片浏览，Enter 应用，Escape 关闭。浏览不会改变桌面。系统和用户主题共用现有目录。优先显示有效的 `preview` 图片；否则用壁纸和配色绘制示意桌面，不保证准确呈现各应用的自定义设置。沿用现有应用事务，保留 Sticky/Spaced，失败后可以重试。JXL 缩略图需要 `libjxl` 中的 `djxl`；XDG 缓存路径为 `argvus/theme-selector/v2`。

按 `/` 可聚焦或离开搜索框；选择器打开后即可输入。**自定义**列出用户安装的主题，**深色**和**浅色**列出对应类别的系统主题。搜索栏与中央预览等宽。Sticky 模式下所有边角为直角；Spaced 保持圆角。紧凑的等宽字体风格与 ARGVUS 桌面工具一致。
