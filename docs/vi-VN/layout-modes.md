---
title: Các chế độ bố cục
description: Chọn bố cục desktop Sticky hoặc Spaced.
---

Sticky giữ các cửa sổ và bề mặt shell gọn gàng. Spaced sử dụng các khoảng trống lớn hơn, các góc bo tròn và lề thanh tác vụ rộng hơn. Chế độ bố cục không phụ thuộc vào chủ đề đã chọn; thay đổi chế độ sẽ áp dụng lại hình học của chế độ đó.

Chọn chế độ trong **Trung tâm Điều khiển → Giao diện → Máy tính để bàn → Chế độ Giao diện** hoặc mở trình chọn của nó với `SUPER + Shift + M`. Cài đặt chuẩn là `/layout/variant`, với các giá trị `sticky` và `spaced`. Các ID chủ đề Spaced đã được giải quyết sử dụng hậu tố `-spaced`. Các giá trị `float` và ID `-float` hiện có vẫn có thể đọc được để tương thích.

`argvus layout-mode-menu` (SUPER + Shift + M): **Tab / Shift+Tab**: Sticky/Spaced ⇄ Tile/Floating · Taskbar Top/Bottom. Chọn Sticky hoặc Spaced bằng ↑/↓. Bốn thẻ bên phải kết hợp cửa sổ lát gạch hoặc nổi với thanh tác vụ ở trên hoặc dưới; ↑/↓/←/→ di chuyển không quay vòng. Nhấp để chọn, Enter để áp dụng, Escape để hủy. Chế độ chưa chọn được làm mờ; bản xem trước dùng giao diện và hình nền hiện tại. Trạng thái chờ vẫn hiển thị và có thể thử lại khi lỗi.

Bộ chọn giao diện và chế độ hiển thị tiến trình trong cửa sổ của mình, không có màn hình chờ phiên. Vị trí cuối của thanh tác vụ được chuẩn bị trước khi tải lại; các lần khởi động lại cần thiết được gộp trong một giao dịch systemd.
