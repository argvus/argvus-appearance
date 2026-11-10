---
title: 布局模式
description: 选择粘性或间隔桌面布局。
---
Sticky 使窗口和外壳表面保持紧凑。Spaced 使用更大的间隙、圆角和更宽的任务栏边距。布局模式与所选主题无关；更改模式会重新应用该模式的几何形状。

在 **控制中心 → 外观 → 桌面 → 外观模式** 中选择模式，或使用 `SUPER + Shift + M` 打开其选择器。规范设置为 `/layout/variant`，值为 `sticky` 和 `spaced`。解析后的 Spaced 主题 ID 使用 `-spaced` 后缀。现有的 `float` 值和 `-float` ID 保持可读以确保兼容性。
