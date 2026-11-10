---
title: 效果
description: 配置动画，全局 Hyprland 模糊和每个表面的透明度。
---
**控制中心 → Hyprland** 包含 **动画**、**模糊** 和 **边框**，其中 **阴影** 页面控制窗口阴影。透明度启用开关是各自外观页面的每个界面设置。

界面开关是独立的。控制中心配置页面有其自身的透明度值和模糊启用开关；其模糊使用全局模糊值。

控制中心通过 Foot 启动，在 `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini` 生成专用配置文件。使用 Foot 1.28 时，透明度会投射到 `[colors-dark] alpha`，界面模糊开关到 `[colors-dark] blur`；普通的 Foot 配置和 ARGVUS 终端保持独立。

## 动画和效果开关

有两个独立的主开关，都通过规范的 /effects 设置应用于 `hyprland.lua`：

- **动画** ( `/effects` `/effects/animations`) 控制所有移动的内容：工作区、窗口、淡入淡出、边框和图层动画。
- **效果** 是模糊 (`/effects/blur_global_enabled`) 以及终端、启动器、小部件遥测、控制面板和任务栏 (`/effects/transparency_<surface>_enabled`) 透明度的快捷方式。开启或关闭它会写入所有这些（以及控制中心的透明度）。每个界面都保留自己的透明度页面，因此当至少有一个开启时，效果会显示为 **开启**，只有当所有界面都关闭时才显示为关闭。

使用 `argvus effects-toggle animations status|enable|disable|toggle` 和 `argvus effects-toggle effects status|enable|disable|toggle`。控制面板外观卡显示每个选项的一个开关。关闭主开关会保留**动画**和**模糊**页面的所有细节设置（速度、曲线、每叶开关、模糊大小和次数），因此再次打开时会恢复相同的效果。当模糊或至少一个透明表面启用时，`effects status` 打印 `enabled`。关闭表面的透明度会使整个 Waybar 表面变为不透明：除了背景，任务栏和小部件遥测的半透明边框会变为在主题背景上显示的纯色。新安装时，所有效果默认启用，包括在虚拟机和低功耗会话中；只有显式设置才会关闭某个效果。

## 同时启用所有效果

`argvus effects-toggle` 在没有组件的情况下同时作用于动画、模糊和透明度：`status` 仅在三者都启用时打印 `enabled`，`enable` 和 `disable` 切换三者，`toggle` 在 `status` 为 `enabled` 时关闭所有功能，否则启用所有功能。**SUPER + F6** 运行此切换。要对单个组操作，请命名它：`argvus effects-toggle animations|effects|blur|transparency status|enable|disable|toggle`。控制中心的 **动画** 页面使用每组件形式，因此其 **启用** 开关仍然仅更改动画。

## 透明度

每个表面都有自己的 **透明度** 子菜单，带有启用开关和值。

**外观 → 启动器** 页面控制官方基于 Rofi 的启动器和选择器流程：主启动器、表情符号选择器、计算器、剪贴板选择器、备忘单和 Rofi 可拆卸设备菜单。其透明度值是最终背景 alpha，因此 `50` 表示背景的不透明度大约为 `0.50`；文本、图标和已选行保持不透明。关闭透明度时，启动器使用活动主题的背景颜色，完全不透明。其模糊开关将 `rofi` 层应用到全局模糊设置中。

每个值的范围从 `0%`（不透明）到 `100%`（完全透明）。以 5% 步长使用 `+` 和 `-`，然后在表面页面上选择 **应用**。离开该页面将放弃未应用的草稿。

使用 `↑` 和 `↓` 在 **Enable** 和 **Value** 之间切换。在 **Value** 行上，`+` 和 `-` 调整草稿而不改变焦点。按 `Tab` 打开 **Actions**，然后激活 **[ Apply ]**；`Esc` 返回到父级界面页面。

## 动画

打开 **Control Center → Hyprland → Animations**。页面上有一个 **Enable** 开关和一个包含 **Custom curves** 的 **Options** 列表，以及五个类别。每个类别列出其动画，每个动画都有自己的页面，包括 **Style**、**Speed**、**Curve**，以及对于窗口打开和关闭的 **Pop-in percentage**。Hyprland 可以关闭的动画也有一个 **Enable** 行。

这些页面上的每一个数值都属于整个动画树共享的一个草稿。在任何一个页面的底部选择 **[ 应用 ]** 之前，没有任何内容会被写入。在页面之间切换会保留草稿；如果在有未应用草稿的情况下离开动画页面，将会要求确认。应用会一次性写入更改的数值并重新加载 Hyprland。顶部的 **启用** 开关是全局动画状态（`effects.animations`）：当它关闭时，无论各自的开关状态如何，每个动画都会被禁用。

控制：`↑/↓` 在行之间移动；`←/→`（或 `+/-`）更改选中的数值并循环 **风格** 和 **曲线**；`Enter` 输入精确的 **速度**、**弹出百分比** 或曲线参数（超出范围的数值会被拒绝），并向前循环 **风格** 和 **曲线**。

### 分类和动画

| 分类 | 动画 | 键 (`effects.animation_<key>_*`) | 风格（默认） | 速度 | 启用 | 
|---|---|---|---|---|---|
|窗户|打开窗户 | `opening` | `popin`，弹出 87% | 4.1 | — |
|窗户|关闭窗户 | `closing` | `popin`，弹出 87% | 1.49 | 1.49 — |
|窗户|移动窗户| `moving` | — | 4.79 | 4.79是的 |
|工作空间 |切换工作空间 | `switching` | `fade` | 1.94 | 1.94 — |
|工作空间 |工作区入口 | `workspace_in` | `fade` | 1.21 | 1.21 — |
|工作空间 |工作区退出 | `workspace_out` | `fade` | 1.94 | 1.94 — |
|工作空间 |特殊工作空间| `special_workspace` | `slide` | 5 | — |
|图层和弹出窗口 |层表面| `layers` | — | 3.81 | 3.81是的 |
|图层和弹出窗口 |层入口| `layers_in` | `fade` | 4 | — |
|图层和弹出窗口 |层出口| `layers_out` | `fade` | 1.5 | 1.5 — |
|图层和弹出窗口 |淡出| `fade` | — | 3.03 | 3.03是的 |
|图层和弹出窗口 |淡入 | `fade_in` | — | 1.73 | 1.73是的 |
|图层和弹出窗口 |淡出| `fade_out` | — | 1.46 | 1.46是的 |
|边框和效果 |边框颜色| `border` | — | 5.39 | 5.39是的 |
| 边框和效果 | 边框渐变角度 | `border_angle` | — | 5 | 是 |
| 其他动画 | 缩放因子 | `zoom` | — | 7 | 是 |
| 其他动画 | 添加显示器 | `monitor_added` | — | 5 | 是 |

Hyprland 0.56.2 在其默认配置中提供的叶子节点的默认值（每一行除特殊工作区、边框渐变角度和添加显示器外）都是默认的速度、样式和曲线。这三项保留 ARGVUS 默认值，因为默认配置没有定义它们。

每个叶子只提供 Hyprland 0.56.2 接受的样式。窗口打开和关闭提供 `slide`、`popin`、`slidefade`、`slidevert`、`slidefadevert` 和 `gnomed`。图层进入和退出提供 `slide`、`popin`、`fade`、`slidefade`、`slidevert` 和 `slidefadevert`。工作区叶子（切换、进入、退出和特殊工作区）提供 `slide`、`fade`、`slidefade`、`slidevert` 和 `slidefadevert`，不包括 `popin` 或 `gnomed`。存储在叶子列表外的样式将被忽略，叶子使用其默认样式。每个动画以 `default` 曲线开始。页面仅提供其动画支持的行。存储的键为 `effects.animation_<key>_speed`、`_curve`、`_style`（在提供的情况下）、`_popin`（窗口打开和关闭）以及 `_enabled`（在提供的情况下）。

### 曲线

| 曲线 | 行为 | 参数（键 → 默认值） |
|---|---|---|
| `default` | Hyprland 0.56.2 为该动画提供的曲线（例如 `easeOutQuint`、`almostLinear`、`quick`、`linear` 或 `easy` 弹簧）。没有标准曲线的动画使用 ARGVUS 内置的贝塞尔曲线。 | 固定 |
| `bezier` | 平滑运动，加速和减速，由两个控制点塑形。 | `bezier_x1` 0.23, `bezier_y1` 1, `bezier_x2` 0.32, `bezier_y2` 1（x 0–1, y −2–3） |
| `spring` | 具有质量、刚度和阻尼的物理运动；可以超调产生弹性效果。 | `spring_mass` 1, `spring_stiffness` 238.1191, `spring_dampening` 24.21279333 |
| `linear` | 整个动画保持恒定速度，从 `(0, 0)` 到 `(1, 1)`。 | 固定 |
| `ease_out` | 开始快速，结束平滑，从 `(0, 0)` 到 `(0.58, 1)`。 | 固定 |

在 **自定义曲线** 下，每条曲线都有自己的页面。Bézier 编辑它的四个控制点，Spring 编辑质量、刚度和阻尼，而 Linear 和 Ease-out 显示它们的固定点。Bézier 和 Spring 的值适用于选择该曲线的每个动画。

范围和步长：**速度** 1–10，可带小数（步长 0.1，默认速度为小数）；**弹出百分比** 1–100，整数（步长 5，默认 87）；Bézier 控制点如上（步长 0.05）；Spring 质量 0.5–10（步长 0.1）、刚度 0.5–2000（步长 10）和阻尼 0.5–200（步长 1）。

未提供：Hyprland 0.56.2 没有针对调整窗口大小、弹出窗口或阴影和光晕渐变角度的单独动画，因此页面不会显示它们的行。

## 模糊

模糊是一个全局的 Hyprland 设置，由所有选择启用的表面共享。打开 **控制中心 → Hyprland → 模糊**。该页面有一个 **启用** 开关和一个 **数值** 列表，包含 Hyprland 的 `decoration:blur` 参数，使用 Hyprland 的命名方式：

| 行 | 配置键 | 默认值 | 范围 | `←/→` 步长 |
|---|---|---|---|---|
| 大小 | `effects.blur_size` | `6` | 1–64 | 1 |
| 迭代次数 | `effects.blur_passes` | `2` | 1–8 | 1 |
| 亮度 | `effects.blur_brightness` | `1` | 0–2 | 0.05 |
| 噪点 | `effects.blur_noise` | `0.00` | 0–1 | 0.01 |
| 对比度 | `effects.blur_contrast` | `0.900000` | 0–2 | 0.05 |
| 鲜艳度 | `effects.blur_vibrancy` | `0.100000` | 0–1 | 0.01 |
| 鲜艳度暗化 | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0.01 |

使用 `↑/↓` 来移动，`←/→`（或 `+/-`）按步长更改所选值，`Enter` 输入精确值；超出范围的值会被拒绝。在编辑时不会写入：开关和数值会保持在草稿中，直到页面底部选择 **[ Apply ]**。应用会一次性写入所有更改的值，并在之后重新加载 Hyprland。未应用草稿离开页面会要求确认。

数值按原样传递给 Hyprland；ARGVUS 不会从百分比推导它们。更改某个表面的开关不会改变数值。

## 阴影

窗口阴影是全局 Hyprland 设置，在 **控制中心 → Hyprland → 边框 → 阴影** 下。它独立于透明度和模糊：默认关闭，开启或关闭表面的透明度不会改变阴影。

| 行 | 配置键 | 默认值 | 范围 | `←/→` 步骤 |
|---|---|---|---|---|
| 启用 | `effects.shadow_enabled` | `false` | — | — |
| 清晰度 | `effects.shadow_sharp` | `false` | — | — |
| 颜色 | `effects.shadow_color` | 空（遵循强调色） | 空或 `RRGGBBAA` | — |
| 范围 | `effects.shadow_range` | `6` | 0–100 | 1 |
| 渲染强度 | `effects.shadow_render_power` | `6` | 1–10 | 1 |
| X 偏移 | `effects.shadow_offset_x` | `0` | −100 到 100 | 1 |
| Y 偏移 | `effects.shadow_offset_y` | `0` | −100 到 100 | 1 |
| 缩放 | `effects.shadow_scale` | `1.00` | 0–1 | 0.05 |

一个空颜色会跟随活动主题的强调色，透明度为 `99`，因此默认的蓝色强调色会给出 `3590bd99`。输入八位十六进制数字（`RRGGBBAA`）来固定颜色，或者留空提示再次跟随强调色。颜色在 Hyprland 配置加载时读取，因此在主题或强调色更改后，会在下次配置重新加载时采用新的强调色。

像模糊效果一样，该页面编辑的是草稿：在选择 **[ 应用 ]** 之前不会写入任何内容，并且在带有未应用草稿的情况下离开页面会要求确认。

## 规范状态和兼容性文件

逻辑偏好存储在 `$XDG_CONFIG_HOME/argvus/config.json` 中。全局动画使用 `effects.animations`；动画值使用上面描述的 `effects.animation_*` 键。全局模糊开关是 `effects.blur_global_enabled`，模糊值使用上面列出的 `effects.blur_*` 键。表面启用状态和透明度值使用如 `effects.blur_control-center_enabled` 和 `effects.transparency_control-center_value` 这样的键。透明度值受限于 `0–100`；每个模糊值受限于其自身范围，`argvus-config` 拒绝写入超出范围的值。启用状态仍然与缺失的覆盖值区分开。

以前的 `effects.blur_global_value` 百分比不再读取。仍然包含它的配置文件会在磁盘上保留此键，但不会生效，而模糊值在其值应用之前使用上述默认值。

```text
$XDG_CONFIG_HOME/argvus/config.json
```
`data/generated/effects/<active-theme>.conf` 是效果投影，仅由 `argvus config` 编写；`argvus effects-toggle` 委托给 `argvus config effects`。主题或模式切换会重新应用活动主题的导出视觉配置文件，包括在存在时来自 `effects.conf` 的每个表面值。没有配置文件的主题会恢复打包的效果默认值。如果希望这些值在再次切换主题或模式时保留，请在更改效果后导出主题。

禁用某个表面的透明度或模糊开关仅影响该表面；保存的数值将在以后重新启用时保留。

## 配置文件

主题导出包括规范的外观/效果设置以及活动主题的每个表面效果投影。在应用主题时，会重新生成生成的 Waybar、Quickshell 和 Hyprland 运行时文件。

所有表面页面都会应用它们的草稿以及 `[ Apply ]` 按钮。控制中心通过效果助手写入规范文档，让 `argvus-config` 投影效果树，重新加载受影响的消费者，并将有效值读取回来。生成的文件会被重新创建，而不是作为权威状态导入。

## 夜间模式

**SUPER + Shift + B** 保持亮度选择器，并添加一个带有效状态/温度的独立夜间模式切换。它调用 `argvus config display night-light status|toggle`。夜间模式需要 Hyprland 并响应 Hyprsunset >= 0.4.0，与亮度支持无关。范围为 1000–20000 K；配置位于控制中心的 **桌面与输入 > 显示器 > 夜间模式**。切换操作是持久的，无需调度，或者是直到下次调度过渡的临时覆盖。取消菜单不会改变任何内容。
