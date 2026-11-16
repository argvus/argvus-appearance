---
title: 布局模式
description: 选择粘性或间隔桌面布局。
---
Sticky 使窗口和外壳表面保持紧凑。Spaced 使用更大的间隙、圆角和更宽的任务栏边距。布局模式与所选主题无关；更改模式会重新应用该模式的几何形状。

在 **控制中心 → 外观 → 桌面 → 外观模式** 中选择模式，或使用 `SUPER + Shift + M` 打开其选择器。规范设置为 `/layout/variant`，值为 `sticky` 和 `spaced`。解析后的 Spaced 主题 ID 使用 `-spaced` 后缀。现有的 `float` 值和 `-float` ID 保持可读以确保兼容性。

`argvus layout-mode-menu` (SUPER + Shift + M): 使用 ↑/↓ 选择 Sticky 或 Spaced。右侧四张卡片组合平铺或浮动窗口与顶部或底部任务栏；←/→ 依次移动，不循环。点击选择，Enter 应用，Escape 取消。未选模式变暗；预览使用当前主题和壁纸。待应用状态会保持显示，失败后可重试。
