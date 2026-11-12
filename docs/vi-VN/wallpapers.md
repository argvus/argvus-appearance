---
title: Hình nền
description: Sử dụng hình nền ARGVUS tích hợp sẵn và tùy chỉnh.
---

Các hình nền JPEG XL tích hợp được cài đặt bởi `argvus-wallpapers` dưới `/usr/share/backgrounds/argvus/`. Trong **Trung tâm điều khiển → Giao diện → Hình nền**, chúng được sắp xếp theo `Abstract` hoặc `Landscape`, sau đó theo `Dark` hoặc `Light`. Các tệp gốc `argvus-dark.jxl` và `argvus-light.jxl` xuất hiện dưới các nhóm dự phòng trừu tượng. Việc chuyển giao diện chỉ sử dụng các tệp trừu tượng trong `abstract/dark` và `abstract/light`; các tệp theo chế độ phong cảnh là lựa chọn thủ công tùy ý. Nhấn `SUPER + Y` để mở trực tiếp màn hình Trung tâm điều khiển này. Mục đầu tiên cũng chấp nhận một hình ảnh tùy chỉnh từ HOME; tệp được chọn sẽ trở thành trạng thái hình nền tùy chỉnh của người dùng.

Mục nhập đầu tiên mở một trình chọn tệp cho hình ảnh tùy chỉnh. Hình nền tùy chỉnh được chọn được lưu dưới dạng `/appearance/wallpaper` cùng với `/appearance/wallpaper_custom` trong cấu hình chuẩn, và `argvus config` chiếu nó vào cấu hình hình nền Hyprland được phiên làm việc sử dụng. Nó vẫn hoạt động cho đến khi một chủ đề hoặc chế độ thay đổi áp dụng lại hình nền của chủ đề đó. Xuất chủ đề đang hoạt động để bao gồm hình nền hiện tại và giữ nó trong chủ đề được xuất. `$XDG_CONFIG_HOME/argvus/.wallpaper-custom` chỉ là đầu vào di cư cũ.

Khi một chủ đề được xuất, hình nền hiện tại sẽ được bao gồm khi nó có thể đọc được. Việc nhập sẽ cài đặt chủ đề; việc áp dụng nó sẽ kích hoạt hình nền của nó. Xem [Nhập và xuất chủ đề](/docs/components/argvus-themes/import-and-export/).

Các điều khiển giao diện người dùng sử dụng trợ lý Hyprland `hypr-wallpaper-pick.sh`, người này cam kết đường dẫn đã chọn thông qua `argvus config` thay vì lưu trạng thái hình nền trực tiếp. Không chỉnh sửa trực tiếp cấu hình hình nền được tạo.
