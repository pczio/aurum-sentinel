# Nguồn dữ liệu — kiểm tra ngày 27/10/2026

## Đang sử dụng

| Nguồn | Dữ liệu / endpoint | Miễn phí, xác thực | Chu kỳ dùng trong app |
| --- | --- | --- | --- |
| [Gold API](https://gold-api.com/faqs) | `https://api.gold-api.com/price/XAU`, `/price/XAG` | Spot không cần key; nhà cung cấp cho phép dùng trong website/thương mại | Cache và kiểm tra tối đa mỗi 30 giây |
| [vang.today](https://www.vang.today/vi/api) | `https://www.vang.today/api/prices` | Công bố miễn phí, không key | Cache 300 giây |
| vang.today lịch sử | `/api/prices?type=XAUUSD&days=30`; cũng dùng SJL1L10, SJ9999 | Không key; dữ liệu ngày | Cache 300 giây; giao diện 7/14/30 ngày |
| [Vietcombank](https://www.vietcombank.com.vn/vi-VN/KHCN/Cong-cu-tien-ich/Ty-gia) | `https://portal.vietcombank.com.vn/Usercontrols/TVPortal.TyGia/pXML.aspx?b=10` | XML công khai cho tham khảo | Nguồn ghi “Only one request every 5 minutes”; app cache 300 giây |
| [Currency API](https://github.com/fawazahmed0/exchange-api) | `https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json` | Dữ liệu CC0, miễn phí, không key | Chỉ là dự phòng FX theo ngày; cache 6 giờ |

Gold API trả giá theo troy ounce và `updatedAt` là lúc chính họ lấy giá từ nguồn, không phải timestamp khớp lệnh. Gold API có cả lịch sử nhưng các endpoint lịch sử cần key và gói miễn phí bị giới hạn, nên bản này lấy lịch sử ngày từ vang.today.

vang.today là nhà tổng hợp độc lập. Không gọi bảng này là API chính thức của SJC, DOJI hay PNJ. Khi kiểm tra trực tiếp, phản hồi thực tế có `prices` dạng object và `timestamp` ở cấp bảng, khác ví dụ `data[]` trên tài liệu. Parser dùng cấu trúc đã nhận thực tế và loại bỏ giá không hợp lệ.

## Ý nghĩa con số

- Bảng giá gốc là **đồng/lượng**. Nhẫn ở thẻ nổi bật chia 10 thành đồng/chỉ. Bảng có tùy chọn hiển thị triệu/lượng hoặc triệu/chỉ.
- “Mua vào” và “bán ra” từ góc nhìn cửa hàng. Két vàng dùng **mua vào** để ước tính bán lại.
- Giá thế giới quy đổi = `XAU_USD × USD_VND × 37.5 / 31.1034768`. Chưa tính thuế, phí, gia công; dữ liệu các nguồn có thể khác thời điểm.
- Tỷ giá dùng **USD bán ra** của Vietcombank. Đây là mốc quy đổi tham khảo, không phải báo giá ngoại hối tick-by-tick. Nếu dự phòng theo ngày, tên nguồn và nhãn thay đổi theo.
- `change_sell` của bảng trong nước là biến động do nguồn công bố; app không tự nhận đó là biến động 24 giờ.
- Biểu đồ nối các quan sát có thật theo ngày; không tự bù điểm thiếu, không chèn giá spot của nhà cung cấp khác vào lịch sử. Ngày hiện tại chưa chốt.

## Khi nguồn chậm

Backend phân biệt `ok`, `stale` (lấy từ bản lưu sau lỗi), `unavailable` (chưa có dữ liệu). Frontend còn kiểm tra tuổi timestamp nguồn. Giá trả được qua HTTP không đồng nghĩa mới cập nhật: mốc nguồn cũ vẫn được ghi rõ.

Khi mất mạng, bản giá gần nhất trong trình duyệt được đánh dấu bản lưu. Cảnh báo chỉ chạy nếu dữ liệu còn đủ mới. Không có giá mặc định hay biến động ngẫu nhiên trong dashboard mới.

Cache trong mỗi runtime gộp các yêu cầu đồng thời; Cloudflare còn đặt TTL cho fetch nguồn. Đây không phải cam kết cập nhật đồng thời toàn thị trường hoặc SLA từ nhà cung cấp miễn phí.

## Lựa chọn khác đã xem

- [MetalpriceAPI](https://metalpriceapi.com/pricing): gói miễn phí công bố 100 requests/tháng và cập nhật theo ngày, không phù hợp để làm nguồn chính cho dashboard tự kiểm tra mỗi 30 giây.
- [TradingView Advanced Chart](https://www.tradingview.com/widget-docs/widgets/charts/advanced-chart/): có widget biểu đồ miễn phí để nhúng. Bản hiện tại dùng SVG tương tác với lịch sử thật từ API, nên dữ liệu chart có thể đối chiếu cùng mã nguồn đang hiển thị.
- [VNAppMob Gold v2](https://api.vnappmob.com/gold.v2.html): tài liệu yêu cầu Bearer key có thời hạn. Không dùng trong phiên bản không cần cấu hình khóa này.

Điều kiện sử dụng và khả dụng của bên cung cấp có thể đổi. Các link trên là nguồn gốc để kiểm tra lại khi đưa vào vận hành.
