---
title: Phông chữ và biểu tượng
description: Cấu hình phông chữ và chủ đề biểu tượng được ARGVUS sử dụng.
---

`argvus-fonts` cài đặt các phông chữ đi kèm theo mục `/usr/share/fonts/`; `argvus-icons` cài đặt các chủ đề biểu tượng ARGVUS. `argvus-appearance` và Trung tâm Điều khiển kết nối các tài nguyên này với chủ đề desktop.

##

Phông chữ chính mặc định của ARGVUS là **IBM Plex Mono**, với kiểu `Regular`. Đây là họ mặc định được sử dụng bởi các mục tiêu phông chữ được hiển thị trong Trung tâm Điều khiển. Gói `argvus-fonts` đi kèm cung cấp IBM Plex Mono và các họ biểu tượng/terminal hỗ trợ được sử dụng bởi máy tính để bàn. Mở

**Trung tâm Điều khiển → Phông chữ** để cấu hình các mục tiêu riêng lẻ:

- thanh tác vụ;
- thông tin từ xa/hệ thống;
- Bảng điều khiển;
- Giao diện hệ thống ARGVUS;
- ứng dụng;
- phần cuối;
- trình duyệt.

Kích thước mặc định phụ thuộc vào từng mục tiêu: thanh tác vụ, hệ thống và terminal sử dụng `13`; theo dõi và Bảng điều khiển sử dụng `14`; ứng dụng sử dụng `12`; và trình duyệt sử dụng `10`. Có thể khôi phục các mặc định này từ trang Phông chữ.

## Chủ đề biểu tượng

Chủ đề biểu tượng đang hoạt động được lưu trữ theo chuẩn dưới dạng `appearance.icon_theme` trong `config.json`. Một giá trị rỗng (mặc định) chọn chủ đề biểu tượng ARGVUS của chế độ chủ đề đang hoạt động: `Argvus Dark Icons` cho các chủ đề tối và `Argvus Light Icons` cho các chủ đề sáng, cả hai đều được cài đặt bởi `argvus-icons`.

`sh/icon-switch.sh` xác định chủ đề hiệu quả và áp dụng nó cho mọi người dùng:

- Cài đặt GNOME: `org.gnome.desktop.interface icon-theme`;
- GTK 3 và GTK 4: `gtk-icon-theme-name` trong các tệp ARGVUS và `settings.ini` gốc;
- Qt: `icon_theme` trong `qt6ct.conf` được quản lý, và trong `qt6ct.conf` gốc khi nó được tạo bởi ARGVUS.

Các chủ đề được tra cứu trong `/usr/share/icons`, `$XDG_DATA_HOME/icons` và `~/.icons`. Một chủ đề đã cấu hình nhưng chưa được cài đặt, hoặc một giá trị chứa `/` hoặc là `..`, sẽ quay về mặc định chế độ tương ứng và ghi một thông báo, vì vậy màn hình desktop sẽ không bao giờ trỏ tới một chủ đề bị thiếu. Việc chuyển chủ đề hoặc chế độ sử dụng lựa chọn biểu tượng từ hồ sơ chủ đề đã xuất khi có, nếu không sẽ khôi phục mặc định chế độ được đóng gói. Xuất chủ đề để giữ lựa chọn biểu tượng tùy chỉnh qua các lần chuyển đổi.

Sử dụng các điều khiển phông chữ trong Trung tâm Điều khiển. Các tùy chọn phông chữ là chuẩn trong `config.json`, tại `fonts.targets.<target>` cho gia đình, kiểu và kích thước cộng với `fonts.rendering` cho khử răng cưa, gợi ý, thứ tự subpixel và DPI. Trung tâm Điều khiển duy trì chúng qua `argvus-config`; nó không tự viết tệp người dùng. `argvus-config` sau đó chiếu `data/generated/fonts.conf` và ghi lại khối phông chữ được phân tách bên trong `data/waybar/argvus-taskbar.css` và `data/waybar/argvus-widget-telemetry.css`, vì vậy các chỉnh sửa phông chữ bên ngoài các khối đó vẫn tồn tại sau khi thay đổi phông chữ. Các quy tắc fontconfig của Terminal và GTK vẫn là các mục tiêu bộ chuyển đổi gốc. Gói chạy cập nhật bộ nhớ đệm phông chữ trong quá trình cài đặt.

Việc tạo mô-đun thanh tác vụ xác thực JSONC kết quả trước khi xuất bản. Các danh sách mô-đun tiện ích được xây dựng lại từ các sở thích được bật, bao gồm một bộ mở rộng ngăn chỉ ở chế độ di chuột. Chế độ biểu tượng không gian làm việc hiển thị `{windows}` cùng với `{name}`. Khả năng hiển thị khay hệ thống chỉ ảnh hưởng đến các biểu tượng ứng dụng nền.


Máy chiếu nhóm tiện ích giữ nguyên tùy chỉnh/AI khi được bật trong các mô-đun Tùy chọn và được định nghĩa bởi mẫu thanh tác vụ. Biểu tượng nf-md-robot của nó (U+F06A9) mở menu các tác nhân AI chia sẻ; khả năng sử dụng vẫn được kiểm soát bởi mô-đun, bao gồm cả khi tất cả các biểu tượng tiện ích khác bị vô hiệu hóa.


Độ hiển thị biểu tượng AI được kiểm soát bởi /taskbar/icons/ai_agents_enabled (mặc định là true), được hiển thị trong Trung tâm điều khiển > Giao diện > Thanh tác vụ > Biểu tượng > Các mô-đun tùy chọn > Tác nhân AI. Máy chiếu tuân thủ trạng thái bị tắt khi áp dụng và giữ lại nhóm tiện ích khi chỉ Tác nhân AI được bật.

Máy chiếu thanh tác vụ đặt Trạng thái Cập nhật vào một nhóm riêng biệt giữa Tiện ích và nhóm mạng/hiệu suất khi `/taskbar/icons/update_status_enabled` đúng. Nó cũng nâng cấp các cấu hình đã tạo cũ với định nghĩa module.

Trợ lý là `argvus window-mode-menu`; `argvus window-mode-menu --status` phát JSON của Waybar. Nó được cung cấp bởi gói chính `argvus`. Các bản sao thanh tác vụ tùy chỉnh hiện có được giữ nguyên: thêm định nghĩa mô-đun `custom/window-mode` và mục nhóm từ mẫu gói để tham gia, hoặc sử dụng Trung tâm Kiểm soát. Máy chiếu giao diện giữ lại mô-đun khi định nghĩa của nó có mặt, ngay cả khi các biểu tượng tiện ích khác bị tắt.

Người tiêu dùng theme `window-bar` và `window-controls` lấy màu sắc của họ từ bg, fg và accent. Màu của thanh tiêu đề tải lại qua `argvus windows decorations`; thanh cửa sổ quan sát bảng kiểu được tạo ra của nó. Tile/Floating độc lập với hình thức xuất hiện Sticky/Spaced.
