/// Hằng số quy đổi thị trường vàng Việt Nam & Quốc tế
class MarketConstants {
  MarketConstants._();

  // Quy chuẩn trọng lượng vàng vật chất
  static const double gramPerTroyOz = 31.1034768;         // 1 Troy Oz = 31.1035 g
  static const double gramPerLuong = 37.5;                // 1 Lượng (Cây) = 37.5 g
  static const double gramPerChi = 3.75;                  // 1 Chỉ = 3.75 g
  static const double gramPerPhan = 0.375;                // 1 Phân = 0.375 g
  static const double ozPerLuong = 1.205653;              // 1 Lượng = 1.205653 Troy Oz
  static const double chiPerLuong = 10.0;                 // 1 Lượng = 10 Chỉ
  static const double phanPerChi = 10.0;                  // 1 Chỉ = 10 Phân

  // Giá trị mặc định chuẩn từ bài toán thực tế
  static const double defaultMonthlyIncome = 15000000.0;   // Lương 15 triệu VNĐ/tháng
  static const List<int> defaultAccumulationLevels = [10, 15, 20, 25, 30]; // % trích tích luỹ
  static const double defaultCurrentRingPrice = 14880000.0; // 14.88 triệu/chỉ nhẫn 9999
  static const double defaultCurrentSjcPrice = 148000000.0; // 148 triệu/lượng SJC
  static const double defaultXauUsd = 4450.0;              // Giá vàng thế giới XAU/USD
  static const double defaultUsdVnd = 26200.0;             // Tỷ giá USD/VND
  static const double defaultImportTaxAndFee = 500000.0;   // Thuế & phí gia công/vận chuyển ước tính

  // Ngưỡng định lượng Arbitrage SJC (ASI Index)
  static const double asiSafeThreshold = 5000000.0;        // ASI <= 5 triệu: Vùng mua an toàn
  static const double asiWarningThreshold = 12000000.0;    // ASI > 12 triệu: Vùng rủi ro cao

  // Hệ số mô hình định lượng giá trị hợp lý XAU (Macro Fair Value Model)
  // Fair Value P* = alpha - beta * TIPS_10Y - gamma * ln(DXY) + delta * CB_Reserves
  static const double macroAlpha = 5200.0;
  static const double macroBetaTIPS = 0.65;                // Trọng số nghịch đảo TIPS 10Y
  static const double macroGammaDXY = 480.0;               // Tác động của đồng USD
  static const double macroDeltaCB = 0.35;                 // Lực đỡ mua ròng NHTW

  // Chỉ số vĩ mô mặc định (khi chưa kết nối FRED API)
  static const double defaultTips10Y = 1.85;               // DFII10: 1.85%
  static const double defaultDxy = 104.2;                  // DXY Index
  static const double defaultCbNetBuyTons = 48.5;          // NHTW mua ròng tấn/tháng

  // Tham số Tích sản & Lãi kép
  static const int defaultStartYear = 2006;
  static const int defaultFutureYears = 10;
  static const double defaultFutureCagr = 12.0;            // Tăng trưởng kỳ vọng 12%/năm
}
