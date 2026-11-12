---
title: Hiệu ứng
description: Định cấu hình hoạt ảnh, độ mờ Hyprland toàn cầu và độ trong suốt trên mỗi bề mặt.
---

**Trung tâm điều khiển → Hyprland** chứa **Hoạt ảnh**, **Blur** và **Biên giới**, có trang **Bóng** điều khiển bóng cửa sổ. Công tắc bật tính minh bạch là cài đặt trên mỗi bề mặt trong các trang Giao diện tương ứng.

Công tắc bề mặt là độc lập. Trang Cấu hình Trung tâm Điều khiển có giá trị Độ trong suốt và công tắc bật Làm mờ riêng; độ mờ của nó sử dụng các giá trị Blur toàn cầu.Trung tâm điều khiển được khởi chạy thông qua Foot với cấu hình được tạo chuyên dụng tại `$XDG_CONFIG_HOME/argvus/data/control-center/foot.ini`. Với Foot 1.28, độ trong suốt được chiếu lên `[colors-dark] alpha` và chuyển Blur bề mặt sang `[colors-dark] blur`; cấu hình Foot bình thường và thiết bị đầu cuối ARGVUS vẫn độc lập.## Công tắc Hoạt hình và Hiệu ứng

Có hai công tắc chính độc lập, cả hai đều được áp dụng cho `hyprland.lua` thông qua các cài đặt chuẩn `/effects`:

- **Hoạt hình** (`/effects/animations`) điều khiển mọi thứ chuyển động: không gian làm việc, cửa sổ, mờ dần, viền và các hoạt hình lớp.
- **Hiệu ứng** là một phím tắt cho hiệu ứng mờ (`/effects/blur_global_enabled`) và độ trong suốt của Terminal, Launcher, Widget Telemetry, Bảng điều khiển và Thanh tác vụ (`/effects/transparency_<surface>_enabled`). Bật hoặc tắt nó sẽ ghi tất cả chúng (và cả độ trong suốt của Trung tâm Điều khiển). Mỗi bề mặt giữ trang độ trong suốt riêng của nó, vì vậy Hiệu ứng sẽ được coi là **bật khi ít nhất một trong số chúng được bật** và sẽ tắt chỉ khi tất cả đều tắt.

Sử dụng `argvus effects-toggle animations status|enable|disable|toggle` và `argvus effects-toggle effects status|enable|disable|toggle`. Bảng điều khiển Giao diện Thẻ hiển thị một quy tắc cho mỗi nút. Việc tắt công tắc chính sẽ giữ nguyên mọi cài đặt tốt của các trang ** Hoạt hình** và **Blur** (tốc độ, đường cong, công tắc trên mỗi lá, kích thước làm mờ và đường sóc), do đó, hãy bật lại công tắc này sẽ khôi phục lại giao diện tương tự. `effects status` trong `enabled` khi bị mờ hoặc có ít nhất một trong các bề mặt trong suốt đó được bật. Việc tắt độ trong suốt của một bề mặt sẽ làm cho toàn bộ bề mặt Waybar mờ đục: ngoài nền, các đường viền mờ của thanh tác vụ và Widget Telemetry trở thành màu đồng nhất mà chúng hiển thị trên nền chủ đề. Theo mặc định, mọi hiệu ứng đều được bật trên bản cài đặt mới, bao gồm cả trên máy ảo và các phiên sử dụng năng lượng thấp; chỉ có một cài đặt rõ ràng sẽ tắt một cái.

## Tất cả các hiệu ứng cùng lúc

`argvus effects-toggle` không có một thành phần nào thao tác trên hoạt ảnh, mờ và trong suốt cùng nhau: `status` in `enabled` chỉ khi cả ba được bật, `enable` và `disable` chuyển đổi cả ba, và `toggle` tắt tất cả mọi thứ khi `status` là `enabled` và bật trong các trường hợp khác. **SUPER + F6** chạy công tắc này. Để thao tác trên một nhóm duy nhất, đặt tên cho nó: `argvus effects-toggle animations|effects|blur|transparency status|enable|disable|toggle`. Trang **Hoạt ảnh** của Trung tâm Điều khiển sử dụng dạng theo thành phần, vì vậy công tắc **Bật** của nó vẫn chỉ thay đổi hoạt ảnh.

## Minh bạch

Mỗi bề mặt có menu con **Độ trong suốt** riêng với công tắc bật và giá trị.

Trang **Appearance → Launchers** kiểm soát các luồng khởi chạy và chọn của Rofi chính thức: trình khởi chạy chính, bộ chọn emoji, máy tính, bộ chọn clipboard, bảng mẹo và menu thiết bị gắn ngoài của Rofi. Giá trị Transparency của nó là alpha nền cuối cùng, vì vậy `50` có nghĩa là độ mờ nền hiệu quả khoảng `0.50`; văn bản, biểu tượng và các hàng được chọn vẫn giữ nguyên độ mờ. Khi tắt Transparency, trình khởi chạy sử dụng màu nền của chủ đề đang hoạt động, hoàn toàn không trong suốt. Công tắc Blur của nó chọn lớp `rofi` vào cài đặt Blur toàn cục.

Mỗi giá trị dao động từ `0%` (mờ đục) đến `100%` (hoàn toàn trong suốt). Sử dụng `+` và `-` theo bước 5%, sau đó chọn **Áp dụng** trên trang bề mặt. Rời khỏi trang sẽ loại bỏ bản nháp chưa được áp dụng.

Sử dụng `↑` và `↓` để di chuyển giữa **Bật** và **Giá trị**. Trên hàng **Giá trị**, `+` và `-` điều chỉnh bản nháp mà không thay đổi tiêu điểm. Nhấn `Tab` để mở **Hành động**, sau đó kích hoạt **[ Áp dụng ]**; `Esc` quay lại trang bề mặt cha.

## Hoạt hình

Mở **Trung tâm điều khiển → Hyprland → Hoạt ảnh**. Trang này có một công tắc **Bật** và một danh sách **Tùy chọn** với **Đường cong tùy chỉnh** và năm danh mục. Mỗi danh mục liệt kê các hoạt ảnh của nó, và mỗi hoạt ảnh có trang riêng với **Phong cách**, **Tốc độ**, **Đường cong** và, đối với việc mở và đóng cửa sổ, **Phần trăm pop-in**. Các hoạt ảnh mà Hyprland có thể tắt cũng có một hàng **Bật**.

Mỗi giá trị trên các trang này thuộc về một bản nháp được chia sẻ bởi toàn bộ cây Hoạt hình. Không có gì được ghi lại cho đến khi **[ Áp dụng ]** được chọn ở cuối bất kỳ trang nào trong số chúng. Di chuyển giữa các trang giữ nguyên bản nháp; rời khỏi trang Hoạt hình với bản nháp chưa áp dụng sẽ yêu cầu xác nhận. Áp dụng sẽ ghi các giá trị đã thay đổi trong một lần và tải lại Hyprland. Công tắc **Bật** ở đầu là trạng thái hoạt hình toàn cục (`effects.animations`): khi nó tắt, mọi hoạt hình đều bị vô hiệu hóa, bất kể công tắc riêng của nó nói gì.

Điều khiển: `↑/↓` di chuyển giữa các hàng; `←/→` (hoặc `+/-`) thay đổi giá trị và chu kỳ đã chọn **Style** và **Curve**; `Enter` nhập chính xác **Tốc độ**, **Tỷ lệ phần trăm bật vào** hoặc tham số đường cong (các giá trị ngoài phạm vi bị từ chối) và chuyển tiếp các chu trình **Style** và **Curve**.

### Danh mục và hoạt ảnh| Category | Animation | Key (`effects.animation_<key>_*`) | Style (default) | Speed | Enable |
|---|---|---|---|---|---|
| Windows | Mở cửa sổ | `opening` | `popin`, bật lên 87% | 4.1 | — |
| Windows | Đóng cửa sổ | `closing` | `popin`, bật lên 87% | 1,49 | — |
| Windows | Cửa sổ di chuyển | `moving` | — | 4,79 | vâng |
| Không gian làm việc | Chuyển đổi không gian làm việc | `switching` | `fade` | 1,94 | — |
| Không gian làm việc | Lối vào không gian làm việc | `workspace_in` | `fade` | 1,21 | — |
| Không gian làm việc | Thoát không gian làm việc | `workspace_out` | `fade` | 1,94 | — |
| Không gian làm việc | Không gian làm việc đặc biệt | `special_workspace` | `slide` | 5 | — |
| Lớp & cửa sổ bật lên | Bề mặt lớp | `layers` | — | 3,81 | vâng |
| Lớp & cửa sổ bật lên | Lối vào lớp | `layers_in` | `fade` | 4 | — |
| Lớp & cửa sổ bật lên | Thoát lớp | `layers_out` | `fade` | 1,5 | — |
| Lớp & cửa sổ bật lên | Mờ dần | `fade` | — | 3.03 | vâng |
| Lớp & cửa sổ bật lên | Làm mờ dần | `fade_in` | — | 1,73 | vâng |
| Lớp & cửa sổ bật lên | Mờ dần | `fade_out` | — | 1,46 | vâng |
| Biên giới & hiệu ứng | Màu viền | `border` | — | 5,39 | vâng |
| Biên giới & hiệu ứng | Góc dốc viền | `border_angle` | — | 5 | vâng |
| Hoạt hình khác | Hệ số thu phóng | `zoom` | — | 7 | vâng |
| Hoạt hình khác | Đã thêm màn hình | `monitor_added` | — | 5 | vâng |

Các mặc định của các mục mà Hyprland 0.56.2 cung cấp trong cấu hình mặc định của nó (mọi hàng ngoại trừ Không gian làm việc Đặc biệt, Góc Gradient viền và Màn hình được thêm) là tốc độ, kiểu dáng và đường cong mặc định. Ba yếu tố này giữ mặc định ARGVUS, vì cấu hình mặc định không định nghĩa chúng.

Mỗi lá chỉ cung cấp các kiểu mà Hyprland 0.56.2 chấp nhận cho nó. Ưu đãi đóng mở cửa sổ `slide`, `popin`, `slidefade`, `slidevert`, `slidefadevert` và `gnomed`. Cung cấp lối vào và lối ra lớp `slide`, `popin`, `fade`, `slidefade`, `slidevert` và `slidefadevert`. Các không gian làm việc rời (chuyển mạch, lối vào, lối ra và không gian làm việc đặc biệt) cung cấp `slide`, `fade`, `slidefade`, `slidevert` và `slidefadevert`, không có `popin` hoặc `gnomed`. Kiểu được lưu trữ bên ngoài danh sách của lá của nó sẽ bị bỏ qua và lá đó sử dụng mặc định của nó. Mọi hoạt ảnh đều bắt đầu bằng đường cong `default`. Một trang chỉ cung cấp các hàng mà hoạt ảnh của nó hỗ trợ. Các khóa được lưu trữ là `effects.animation_<key>_speed`, `_curve`, `_style` (nếu được cung cấp), `_popin` (mở và đóng cửa sổ) và `_enabled` (nếu được cung cấp).

### Đường cong

| Đường cong | Hành vi | Tham số (khóa → mặc định) |
|---|---|---|
| `default` | Đường cong Hyprland 0.56.2 được cung cấp cho hoạt ảnh đó (ví dụ: `easeOutQuint`, `almostLinear`, `quick`, `linear` hoặc lò xo `easy`). Hoạt ảnh không có đường cong gốc sử dụng Bézier tích hợp sẵn của ARGVUS. | Đã sửa. |
| `bezier` | Chuyển động mượt mà tăng tốc và giảm tốc, được định hình bởi hai điểm kiểm soát. | `bezier_x1` 0,23, `bezier_y1` 1, `bezier_x2` 0,32, `bezier_y2` 1 (x 0–1, y −2–3) |
| `spring` | Chuyển động vật lý có khối lượng, độ cứng và độ giảm chấn; nó có thể vượt quá để tạo ra hiệu ứng đàn hồi. | `spring_mass` 1, `spring_stiffness` 238.1191, `spring_dampening` 24.21279333 || `linear` | Tốc độ không đổi cho toàn bộ hoạt hình, từ `(0, 0)` to `(1, 1)`. | Fixed. |
| `ease_out` | Nhanh chóng lúc bắt đầu và mượt mà ở cuối, từ `(0, 0)` to `(0.58, 1)`. | Fixed. |

Dưới **Đường cong tùy chỉnh**, mỗi đường cong có một trang riêng. Bézier chỉnh bốn điểm điều khiển của nó, Spring chỉnh khối lượng, độ cứng và giảm chấn, và Linear cùng Ease-out hiển thị các điểm cố định của chúng. Các giá trị Bézier và Spring áp dụng cho mọi hoạt hình chọn đường cong đó.

Phạm vi và các bước: **Tốc độ** 1–10 với số thập phân (bước 0,1, tốc độ mặc định là số thập phân); **Phần trăm xuất hiện đột ngột (Pop-in)** 1–100 theo số nguyên (bước 5, mặc định 87); Điểm Bézier như trên (bước 0,05); Khối lượng lò xo 0,5–10 (bước 0,1), độ cứng 0,5–2000 (bước 10) và giảm chấn 0,5–200 (bước 1).

Không được cung cấp: Hyprland 0.56.2 không có hoạt ảnh riêng cho việc thay đổi kích thước cửa sổ, cho các cửa sổ bật lên, hoặc cho các góc gradient của bóng và ánh sáng, vì vậy trang không hiển thị các hàng cho chúng.

## Làm mờ

Blur là một cài đặt toàn cầu của Hyprland, được chia sẻ bởi mọi bề mặt chọn tham gia. Mở **Control Center → Hyprland → Blur**. Trang này có một công tắc **Enable** và một danh sách **Values** với các tham số của `decoration:blur` của Hyprland, theo các tên mà Hyprland sử dụng:

| Hàng | Phím cấu hình | Mặc định | Phạm vi | Bước `←/→` |
|---|---|---|---|---|
| Kích thước | `effects.blur_size` | `6` | 1–64 | 1 |
| Vượt qua | `effects.blur_passes` | `2` | 1–8 | 1 |
| Độ sáng | `effects.blur_brightness` | `1` | 0–2 | 0,05 |
| Tiếng ồn | `effects.blur_noise` | `0.00` | 0–1 | 0,01 |
| Tương phản | `effects.blur_contrast` | `0.900000` | 0–2 | 0,05 |
| Sống động | `effects.blur_vibrancy` | `0.100000` | 0–1 | 0,01 |
| Bóng tối sống động | `effects.blur_vibrancy_darkness` | `0` | 0–1 | 0,01 |

Use

 để di chuyển, `↑/↓` (hoặc `←/→`) để thay đổi giá trị đã chọn theo bước của nó và `+/-` `Enter` để nhập một giá trị chính xác; các giá trị ngoài phạm vi bị từ chối. Không có gì được viết trong khi bạn chỉnh sửa: nút chuyển và các giá trị vẫn ở dạng bản nháp cho đến khi **[ Áp dụng ]** ở cuối trang được chọn. Áp dụng ghi mọi giá trị đã thay đổi trong một cuộc gọi và tải lại Hyprland sau đó. Để lại trang có bản nháp chưa được áp dụng sẽ yêu cầu xác nhận.

Các giá trị được truyền đến Hyprland nguyên vẹn; ARGVUS không suy ra chúng từ phần trăm. Thay đổi công tắc của một bề mặt không thay đổi các giá trị.

## Bóng tối

Bóng cửa sổ là một cài đặt toàn cục của Hyprland, nằm trong **Control Center → Hyprland → Borders → Shadow**. Nó độc lập với độ trong suốt và làm mờ: mặc định tắt, và bật hoặc tắt độ trong suốt của một bề mặt không thay đổi nó.

| Hàng | Phím cấu hình | Mặc định | Phạm vi | Bước `←/→` |
|---|---|---|---|---|
| Bật | `effects.shadow_enabled` | `false` | — | — |
| Sắc nét | `effects.shadow_sharp` | `false` | — | — |
| Màu sắc | `effects.shadow_color` | trống (theo dấu) | trống hoặc `RRGGBBAA` | — |
| Phạm vi | `effects.shadow_range` | `6` | 0–100 | 1 |
| Kết xuất sức mạnh | `effects.shadow_render_power` | `6` | 1–10 | 1 |
| Bù đắp X | `effects.shadow_offset_x` | `0` | −100 đến 100 | 1 |
| Bù đắp Y | `effects.shadow_offset_y` | `0` | −100 đến 100 | 1 |
| Quy mô | `effects.shadow_scale` | `1.00` | 0–1 | 0,05 |

Màu trống đi theo điểm nhấn của chủ đề đang hoạt động với alpha `99`, do đó, điểm nhấn màu xanh lam mặc định sẽ tạo ra `3590bd99`. Nhập tám chữ số thập lục phân (`RRGGBBAA`) để sửa màu hoặc để trống lời nhắc để theo dõi lại dấu. Màu được đọc khi cấu hình Hyprland tải, do đó, sau khi thay đổi chủ đề hoặc giọng, nó sẽ lấy giọng mới trong lần tải lại cấu hình tiếp theo.

Giống như Blur, trang chỉnh sửa bản nháp: không có gì được viết cho đến khi **[ Áp dụng ]** được chọn và việc rời khỏi trang có bản nháp chưa được áp dụng sẽ yêu cầu xác nhận.

## Các tệp tương thích và trạng thái CanonicalSở thích logic được lưu trong `$XDG_CONFIG_HOME/argvus/config.json`. Hoạt ảnh toàn cục sử dụng `effects.animations`; các giá trị Hoạt ảnh sử dụng các khóa `effects.animation_*` được mô tả ở trên. Công tắc Mờ toàn cục là `effects.blur_global_enabled`, và các giá trị Mờ sử dụng các khóa `effects.blur_*` được liệt kê ở trên. Trạng thái bật bề mặt và các giá trị trong suốt sử dụng các khóa như `effects.blur_control-center_enabled` và `effects.transparency_control-center_value`. Các giá trị trong suốt bị giới hạn ở `0–100`; mỗi giá trị Mờ bị giới hạn trong phạm vi riêng của nó, và `argvus-config` từ chối các ghi ngoài phạm vi này. Trạng thái bật vẫn khác biệt với ghi đè bị thiếu.

Phần trăm `effects.blur_global_value` trước đây không còn được đọc. Một hồ sơ vẫn chứa nó sẽ giữ khóa trên đĩa mà không có tác dụng, và Blur sử dụng các giá trị mặc định ở trên cho đến khi các giá trị của nó được áp dụng.

```text
$XDG_CONFIG_HOME/argvus/config.json
```

`data/generated/effects/<active-theme>.conf` là dự báo hiệu ứng, chỉ được viết bởi `argvus config`; `argvus effects-toggle` ủy quyền cho `argvus config effects`. Việc chuyển đổi chủ đề hoặc chế độ sẽ áp dụng lại hồ sơ hình ảnh đã xuất của chủ đề đang hoạt động, bao gồm các giá trị từng bề mặt từ `effects.conf` khi có. Các chủ đề không có hồ sơ sẽ khôi phục các giá trị hiệu ứng mặc định được đóng gói. Xuất chủ đề sau khi thay đổi hiệu ứng nếu bạn muốn những giá trị đó tồn tại sau lần chuyển đổi chủ đề hoặc chế độ khác.

Vô hiệu hóa công tắc Độ trong suốt hoặc Làm mờ của một bề mặt chỉ ảnh hưởng đến bề mặt đó; các giá trị số đã lưu được giữ lại để sử dụng khi bật lại sau. Xuất chủ đề

## Hồ sơ

bao gồm các cài đặt giao diện/hiệu ứng chuẩn và chiếu hiệu ứng từng bề mặt của chủ đề đang hoạt động. Các tệp chạy thời gian của Waybar, Quickshell và Hyprland được tạo lại khi áp dụng chủ đề.

Tất cả các trang bề mặt áp dụng các bản nháp của chúng cùng với nút `[ Apply ]`. Trung tâm điều khiển ghi tài liệu chuẩn thông qua trợ giúp hiệu ứng, cho phép `argvus-config` tạo cây hiệu ứng, tải lại các người tiêu dùng bị ảnh hưởng và đọc lại giá trị hiệu quả. Các tệp được tạo ra được tạo lại thay vì nhập như trạng thái chính thức.

## Đèn ban đêm

**SUPER + Shift + B** giữ nguyên bộ chọn độ sáng và thêm nút chuyển đổi Đèn ngủ riêng biệt với trạng thái/nhiệt độ hiệu quả. Nó gọi `argvus config display night-light status|toggle`. Night Light yêu cầu Hyprland và Hyprsunset phản hồi >= 0,4.0, độc lập với hỗ trợ độ sáng. Phạm vi là 1000–20000 K; cấu hình nằm trong **Máy tính để bàn & Đầu vào > Hiển thị > Đèn ngủ** trong Trung tâm điều khiển. Chuyển đổi liên tục mà không cần lên lịch hoặc ghi đè không ổn định until the next transition with scheduling. Cancelling the menu changes nothing.
