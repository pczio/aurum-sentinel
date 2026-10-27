# Kiểm tra MVP Web v2 — 27/10/2026

## Kết quả

- `npm test`: **19/19** bài kiểm tra qua. Ngoài 13 bài cho giá/kế hoạch/két vàng, thêm 6 bài cho RSS: CDATA/entity, múi giờ, giới hạn link/DTD, sắp xếp/gộp trùng, hôm nay theo UTC+7, cache đồng thời, lỗi từng nguồn và hết hạn bản lưu.
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

## Thanh giá và bàn tin RSS

- Node preview nhận dữ liệu RSS thật từ Vietstock và Federal Reserve; 2 tin vàng trong ngày xuất hiện với đúng giờ đăng và link nguồn.
- Chrome xác nhận thanh giá chạy thật, nút dừng từng thanh, bản sao marquee ẩn khỏi cây truy cập bằng `aria-hidden` và `inert`.
- Quan sát ô tin tự chuyển `01 / 02` sang `02 / 02`; kiểm tra tạm dừng giữ nguyên vị trí, nút lên/xuống, chuyển chủ đề Fed với nhãn chưa có tin hôm nay.
- Tin cuối quay về tin đầu bằng đúng một nấc đi lên; bản sao chuyển vòng luôn `inert`/ẩn với trình đọc màn hình. Danh sách chủ đề Fed hiển thị đủ 6 bài và tự cuộn đến bài đang chọn.
- Hover hoặc đặt focus vào ô tin giữ nguyên vị trí; khi rời ô tin thì tự chuyển tiếp. Đã thử lại thêm giao dịch két vàng và mở bảng nguồn dữ liệu trong giao diện mới.
- Mất mạng RSS: giữ lại tiêu đề, đánh dấu bản lưu. Khi tất cả nguồn chưa có dữ liệu: trạng thái trống có nút thử lại, không tạo tin mẫu.
- Cài đặt giảm chuyển động: thanh giá đứng yên, có thể cuộn ngang; không tự chuyển ô tin, vẫn đọc bằng nút trước/sau.
- Giao diện mới không tràn ngang ở 390, 768, 1024, 1440 và 1920 px; tin đang chọn khớp đúng mép cửa sổ chuyển dọc trên điện thoại.
- `wrangler deploy --dry-run` nhận Worker mở rộng RSS và 9 browser assets. Kiểm tra thêm bằng Pages/workerd để xác nhận `/api/news` hoạt động trong runtime Cloudflare.
- Khắc phục khác biệt Node/workerd: Vietstock trả HTTP 403 khi User-Agent rỗng. Backend gửi định danh công khai `AurumSentinel/2.0` cùng link repo; xác nhận phản hồi 200 bằng workerd, không giả danh trình duyệt.

## Hình giao diện

- [Desktop — màn hình đầu](dashboard-desktop.png)
- [Mobile](dashboard-mobile.png)
- [Bàn tin RSS](market-news-desk.png)

## Giới hạn còn lại

- Chưa publish hoặc kiểm tra trên một domain Cloudflare production trong phiên này.
- Giá Việt Nam là nguồn tổng hợp độc lập; mốc công bố có thể giữ nguyên dù app vẫn lấy được phản hồi. Chưa đối soát từng báo giá với quầy giao dịch.
- Kế hoạch là mô phỏng theo giả định; chưa tính mọi loại thuế, phí và quy cách vàng bán lẻ.
- Két vàng lưu theo trình duyệt/địa chỉ website. Cảnh báo chỉ hoạt động khi trang mở, chưa có push nền.
