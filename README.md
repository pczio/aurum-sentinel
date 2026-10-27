# AurumSentinel Web — MVP v2

Bản web dành cho trình duyệt: dashboard nhiều ô, bảng giá thật, biểu đồ lịch sử, kế hoạch tích sản, cảnh báo và két vàng cá nhân. Giao diện HTML/CSS/JavaScript độc lập với Flutter. App Flutter gốc trên máy được giữ nguyên; mã Dart sao chép được giữ trong repo để tham khảo.

## Mở trên máy

**Nhấp đúp `Mo-AurumSentinel.cmd`.** Cần Node.js 22+; không cần Flutter hoặc cài npm để xem web. File mở nhanh tự build các tệp web và mở trình duyệt.

- Địa chỉ mặc định `http://127.0.0.1:8787/`.
- Nếu app cũ đang chiếm cổng, launcher tự chọn cổng trống tiếp theo và mở đúng địa chỉ đó.
- Giữ cửa sổ chạy app mở khi dùng. Nhấn Ctrl+C hoặc đóng cửa sổ để dừng.
- Để chuyển dữ liệu Flutter cũ trên cùng địa chỉ `127.0.0.1:8787`, đóng cửa sổ server cũ rồi mở launcher mới. Dữ liệu két cũ được chuyển nếu tồn tại trong localStorage của cùng địa chỉ. Các món chưa ghép được đúng sản phẩm sẽ được giữ lại với trạng thái chưa định giá.
- `web/index.html` là mã nguồn web; mở bằng `file://` chỉ có hướng dẫn. Cần HTTP/HTTPS cho API và JavaScript module.

Hoặc chạy:

```powershell
git clone https://github.com/pczio/aurum-sentinel.git
cd aurum-sentinel
npm run build
npm start
```

## Dữ liệu thật và tần suất

| Dữ liệu | Nguồn | Cách cập nhật |
| --- | --- | --- |
| Vàng XAU/USD, bạc XAG/USD | [Gold API](https://gold-api.com/faqs) | API miễn phí, không cần key; nguồn công bố khoảng 30 giây |
| SJC, DOJI, PNJ, Bảo Tín… | [vang.today](https://www.vang.today/vi/api) | Nguồn tổng hợp độc lập, công bố khoảng 5 phút; không phải API trực tiếp của các thương hiệu |
| Lịch sử 7/14/30 ngày | vang.today | Điểm giá theo ngày; ngày hiện tại chưa chốt, không phải tick intraday |
| USD/VND | XML công khai Vietcombank | Giá USD bán ra; server lấy tối đa mỗi 5 phút |
| Tỷ giá dự phòng | [Currency API](https://github.com/fawazahmed0/exchange-api) | Chỉ khi Vietcombank không phản hồi; theo ngày, có nhãn riêng |
| Tin vàng & kim loại quý | [Vietstock RSS](https://vietstock.vn/rss) | RSS chuyên mục vàng; kiểm tra mỗi 5 phút, ưu tiên tin hôm nay |
| Fed & lãi suất | [Federal Reserve RSS](https://www.federalreserve.gov/feeds/feeds.htm) | Thông cáo chính sách tiền tệ chính thức; kiểm tra mỗi 5 phút |

Trang kiểm tra giá mỗi 30 giây khi đang mở. Mỗi nguồn có cache riêng để tránh gọi dồn. Có mốc cập nhật do nguồn cung cấp dưới từng giá. Không tạo biến động ngẫu nhiên hoặc thay giá thật bằng số mẫu.

Nguồn không phản hồi sẽ có trạng thái chưa có dữ liệu hoặc bản lưu. Ngày nghỉ/ngoài phiên, giá có thể giữ nguyên. Một mốc bảng giá tổng hợp không đồng nghĩa từng sản phẩm đã đổi giá ở mốc đó.

Xem [ghi chú nguồn API](docs/DATA_SOURCES.md) và nút **Nguồn dữ liệu** trên website.

## Tính năng

- Dashboard rộng với 4 chỉ số, biểu đồ tương tác, diễn giải chênh lệch, tỷ giá và tỷ lệ vàng/bạc.
- Thanh giá chạy ngang ở đầu trang: XAU/USD, XAG/USD, giá bán vàng trong nước và USD/VND, kèm đơn vị, mốc nguồn và nhãn giá cũ nếu cần. Biến động trong nước theo nguồn công bố, không tự gán là 24 giờ.
- Dòng tin vàng cố định ở cuối màn hình, liên kết tới bài gốc. Bàn tin RSS chuyển dọc từng bài mỗi 7 giây, chọn chủ đề vàng hoặc Fed, nút trước/sau và tạm dừng. Ưu tiên bài đăng trong ngày theo giờ Việt Nam; chưa có bài hôm nay sẽ ghi rõ tin gần nhất.
- Thanh chạy dừng khi rê chuột, dùng bàn phím hoặc bấm tạm dừng. Ô tin dừng khi rê chuột/đặt focus vào ô; tôn trọng cài đặt giảm chuyển động của hệ điều hành. Chỉ lấy tiêu đề, giờ đăng và link nguồn; không sao chép nội dung bài báo.
- Bảng 10 sản phẩm khi nguồn đủ dữ liệu, lọc nhóm, tìm thương hiệu, đổi đơn vị lượng/chỉ và tải CSV.
- Kế hoạch tích sản: thu nhập, ngân sách %, thời gian, giả định tăng/giảm giá. Đây là mô phỏng do người dùng chọn, không phải dự báo hay lợi nhuận cam kết. Mô hình mua lượng vàng lẻ cuối tháng; thực tế cần đối chiếu quy cách bán và phí.
- Két vàng ghi giao dịch, định giá bán lại theo **giá mua vào** của cửa hàng, hiển thị rõ phần chưa định giá. Sao lưu JSON và khôi phục có kiểm tra, không ghi đè giao dịch đã có cùng ID.
- Cảnh báo theo ngưỡng XAU/SJC/nhẫn, phát một lần khi có dữ liệu mới hợp lệ và trang đang mở. Chưa có Web Push hoặc chạy nền khi đóng trang.
- Kiến thức đơn vị, cách đọc mua/bán, nguồn dữ liệu và tình trạng kết nối.

Két vàng, cảnh báo và kế hoạch lưu trong trình duyệt, không gửi lên server. Chưa có tài khoản hoặc đồng bộ nhiều máy. Dữ liệu gắn với địa chỉ website; dùng Sao lưu/Khôi phục khi đổi trình duyệt hoặc chuyển từ localhost lên Cloudflare.

## Build, kiểm tra

```powershell
npm ci
npm test
npm run build
npm run preview
```

`npm test` dùng Node test runner; không cần Flutter. Mã Dart cũ và tests Flutter được giữ để tham khảo; `npm run test:flutter` chạy bộ cũ. Template web Flutter trước đây nằm trong `legacy_flutter/`.

Đầu ra hiện tại là **`dist/`**, không dùng `build/web/` của bản Flutter cũ.

```powershell
npm run preview:cloudflare
npm run preview:pages
```

Hai lệnh lần lượt kiểm tra Workers tại 8789 và Pages tại 8790.

## Deploy Cloudflare Workers

```powershell
npm ci
npx wrangler login
npm run deploy
```

`npm run deploy` tự build trước khi deploy. `wrangler.jsonc` phục vụ `dist/` và chạy `server/worker.mjs` cho `/api/*`. Không cần API key với các nguồn hiện dùng.

Nếu đã có `dist/` mới nhất: `npm run deploy:prebuilt`.

Nếu kết nối repo GitHub `pczio/aurum-sentinel` trong Cloudflare, đặt thư mục gốc là `/` (root repo), build command `npm run build`, deploy command `npx wrangler deploy`.

## Deploy Cloudflare Pages

Pages dùng cấu hình chuẩn riêng tại `pages/wrangler.jsonc`, vì phiên bản Wrangler hiện tại không hỗ trợ tùy chọn `--config` cho Pages.

```powershell
npx wrangler login
npx wrangler pages project create aurumsentinel-mvp --cwd pages --production-branch main
npm run deploy:pages
```

Chỉ tạo project lần đầu. Đổi tên project trong `pages/wrangler.jsonc` nếu dùng tên khác. `dist/_worker.js` phục vụ API qua Pages Advanced Mode; `dist/_routes.json` chỉ cho `/api/*` đi qua Worker. Đưa cả đầu ra lên cùng nhau, không chỉ upload một file HTML.

Hướng dẫn Cloudflare: [Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/), [Pages Advanced Mode](https://developers.cloudflare.com/pages/functions/advanced-mode/).

## Cấu trúc

```text
web/                   Giao diện web và các phép tính phía trình duyệt
server/worker.mjs      API nguồn dữ liệu, parser, cache, fallback; dùng chung Node/Cloudflare
scripts/build.mjs      Build web không cần Flutter; tạo dist và Worker cho Pages
scripts/preview.mjs    Web server trên máy, cùng logic API như Cloudflare
pages/wrangler.jsonc   Cấu hình Pages
wrangler.jsonc         Cấu hình Workers
cloudflare/_headers    Quy tắc header HTTP
Mo-AurumSentinel.cmd   Mở web bằng một lần nhấp
test-web/              Kiểm tra dữ liệu, cache, tính toán và sao lưu
dist/                  Bản deploy hiện tại
legacy_flutter/        Template Flutter web trước lần nâng cấp giao diện
lib/, test/            Bản sao mã Dart cũ để tham khảo
```

Xem [kết quả kiểm tra](docs/VALIDATION.md). Chưa publish lên tài khoản Cloudflare trong phiên làm việc này.
