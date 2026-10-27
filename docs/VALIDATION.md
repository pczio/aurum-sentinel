# Kiểm tra MVP Web v2 — 27/10/2026

## Kết quả

- `npm test`: **13/13** bài kiểm tra qua. Kiểm tra đơn vị ounce/lượng/chỉ, premium, DCA tăng trưởng âm và chênh mua–bán, định giá bán lại, parser nguồn thật, múi giờ Vietcombank, lịch sử không bù giá, cache gộp yêu cầu, mất nguồn, route API và file sao lưu.
- `npm run build`: thành công. Giao diện tạo từ HTML/CSS/JS; không cần Flutter. Đầu ra `dist/` kèm Worker API cho Pages.
- `npx wrangler deploy --dry-run`: thành công, binding ASSETS được nhận. Đây không phải publish.
- Chạy API thật bằng cả Node local, Wrangler Workers và Wrangler Pages. Cả ba nhận được XAU/XAG, 10 sản phẩm trong nước, tỷ giá Vietcombank và lịch sử 7 ngày.
- Chrome: không có lỗi JavaScript trong lượt kiểm tra chức năng. Đã xác nhận không tràn ngang trang ở 390, 768, 1024, 1440 và 1920 px.

## Luồng đã thử qua giao diện

1. Tìm DOJI, lọc nhẫn, đổi bảng từ lượng sang chỉ.
2. Chuyển biểu đồ 30 sang 7 ngày và từ XAU sang SJC; giá và đơn vị đổi đúng.
3. Chỉnh thu nhập, tỷ lệ tích sản; kế hoạch lưu qua lần tải lại.
4. Thêm giao dịch; định giá theo mua vào; tải lại vẫn giữ giao dịch.
5. Tải sao lưu JSON và khôi phục cùng file; không tạo giao dịch trùng ID.
6. Tạo cảnh báo đủ điều kiện, xác nhận chạm ngưỡng và lưu trạng thái qua reload.
7. Xuất bảng giá CSV, mở bảng giải thích nguồn dữ liệu.
8. Giả lập mất kết nối API: giữ nguyên giá đã có, gắn nhãn bản lưu, không tạo giá thay thế; khôi phục mạng lấy lại nguồn.
9. Quan sát lần tự kiểm tra sau 30 giây: timestamp Gold API từ `08:30:53Z` lên `08:31:23Z`, xác nhận poll hoạt động với nguồn thật.
10. Mở dashboard qua Pages tại cổng kiểm tra 8790: Worker API và biểu đồ chạy thành công.
11. Chuyển két vàng Flutter cũ sang web trên cùng origin: xác nhận 1 lượng thành 10 chỉ, giá vốn mỗi lượng thành giá vốn mỗi chỉ và giữ nguyên tổng vốn.

Các giao dịch thử nằm trong profile Chrome kiểm tra riêng, không ghi vào két vàng của người dùng.

## Hình giao diện

- [Desktop — màn hình đầu](dashboard-desktop.png)
- [Mobile](dashboard-mobile.png)

## Giới hạn còn lại

- Chưa publish hoặc kiểm tra trên một domain Cloudflare production trong phiên này.
- Giá Việt Nam là nguồn tổng hợp độc lập; mốc công bố có thể giữ nguyên dù app vẫn lấy được phản hồi. Chưa đối soát từng báo giá với quầy giao dịch.
- Kế hoạch là mô phỏng theo giả định; chưa tính mọi loại thuế, phí và quy cách vàng bán lẻ.
- Két vàng lưu theo trình duyệt/địa chỉ website. Cảnh báo chỉ hoạt động khi trang mở, chưa có push nền.
