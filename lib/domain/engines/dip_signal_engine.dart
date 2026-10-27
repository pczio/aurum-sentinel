import 'dart:math' as math;
import '../../core/utils/math_utils.dart';
import '../models/dip_signal_models.dart';

/// Cỗ máy định lượng Phát hiện nhịp giảm & Bắt đáy vàng (Dip-Buying Radar)
class DipSignalEngine {
  DipSignalEngine._();

  /// Đánh giá nhịp giảm dựa trên chuỗi giá lịch sử ngắn hạn gần nhất
  static DipSignal evaluateDip({
    required List<double> recentPrices,
    required double currentPrice,
    required double regularMonthlyDcaBudget,
  }) {
    if (recentPrices.isEmpty) {
      return DipSignal(
        isDip: false,
        severity: DipSeverity.none,
        currentPrice: currentPrice,
        peakPrice30d: currentPrice,
        drawdownPercent: 0.0,
        rsi14: 50.0,
        ema20: currentPrice,
        extraBudgetMultiplier: 1.0,
        suggestedBuyVnd: regularMonthlyDcaBudget,
        title: 'Chưa đủ dữ liệu chuỗi nến',
        rationale: 'Cần ít nhất 14 phiên giá để kích hoạt chỉ báo kỹ thuật RSI & EMA.',
        detectedAt: DateTime.now(),
      );
    }

    // Tìm đỉnh cao nhất trong 30 phiên gần nhất
    final int lookback = math.min(30, recentPrices.length);
    final subList = recentPrices.sublist(recentPrices.length - lookback);
    final double peakPrice = subList.reduce(math.max);

    // Tính độ sụt giảm từ đỉnh gần nhất
    final double drawdown = MathUtils.calculateDrawdown(
      currentPrice: currentPrice,
      peakPrice: peakPrice,
    );

    // Tính chỉ báo RSI 14
    final double rsi = MathUtils.calculateRsi(recentPrices, period: 14);

    // Tính đường trung bình động EMA 20
    final List<double> emaList = MathUtils.calculateEma(recentPrices, 20);
    final double ema20 = emaList.isNotEmpty ? emaList.last : currentPrice;

    final DipSeverity severity;
    final double multiplier;
    final String title;
    final String rationale;
    final bool isDip;

    if (drawdown <= -7.0 || rsi < 32.0) {
      severity = DipSeverity.deepOversold;
      isDip = true;
      multiplier = 1.5; // Gợi ý tăng thêm 50% ngân sách bắt đáy
      title = 'CƠ HỘI VÀNG: BẮT ĐÁY QUÁ BÁN SÂU';
      rationale =
          'Giá vàng đã chiết khấu mạnh ${drawdown.abs().toStringAsFixed(1)}% từ đỉnh 30 ngày và RSI rơi vào vùng quá bán sâu (${rsi.toStringAsFixed(1)}). Lịch sử chu kỳ giá vàng cho thấy giải ngân tăng cường tại vùng này mang lại biên an toàn vốn vượt trội.';
    } else if (drawdown <= -4.0 || rsi < 42.0) {
      severity = DipSeverity.strongDip;
      isDip = true;
      multiplier = 1.25; // Gợi ý tăng thêm 25%
      title = 'NHỊP ĐIỀU CHỈNH ĐẸP: TĂNG TỐC TÍCH SẢN';
      rationale =
          'Thị trường vàng trong nước điều chỉnh kỹ thuật lành mạnh -${drawdown.abs().toStringAsFixed(1)}% dưới đường EMA20. Đây là thời điểm lý tưởng để trích thêm một phần quỹ nhàn rỗi gom thêm vàng nhẫn 9999.';
    } else if (drawdown <= -2.0) {
      severity = DipSeverity.mildDip;
      isDip = true;
      multiplier = 1.1; // Tăng nhẹ 10%
      title = 'CHIẾT KHẤU NHẸ: ĐIỂM VÀO DCA HỢP LÝ';
      rationale =
          'Giá vàng hạ nhiệt nhẹ -${drawdown.abs().toStringAsFixed(1)}%. Mua vào đúng nhịp nhận lương mà không gặp rủi ro mua đuổi đỉnh.';
    } else {
      severity = DipSeverity.none;
      isDip = false;
      multiplier = 1.0;
      title = 'THỊ TRƯỜNG ĐI NGANG HOẶC TĂNG';
      rationale =
          'Giá vàng đang neo sát vùng đỉnh ngắn hạn (${drawdown.toStringAsFixed(1)}%). Bạn nên duy trì kế hoạch DCA định kỳ thông thường, không nên nóng vội giải ngân vượt hạn mức.';
    }

    final double suggestedBuyVnd = regularMonthlyDcaBudget * multiplier;

    return DipSignal(
      isDip: isDip,
      severity: severity,
      currentPrice: currentPrice,
      peakPrice30d: peakPrice,
      drawdownPercent: drawdown,
      rsi14: rsi,
      ema20: ema20,
      extraBudgetMultiplier: multiplier,
      suggestedBuyVnd: suggestedBuyVnd,
      title: title,
      rationale: rationale,
      detectedAt: DateTime.now(),
    );
  }
}
