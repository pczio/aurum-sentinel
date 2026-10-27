import 'package:flutter/material.dart';
import '../../core/constants/aurum_colors.dart';

enum DipSeverity {
  none,        // Thị trường bình thường / tăng
  mildDip,     // Giảm nhẹ 2 - 4%: Điểm DCA tốt
  strongDip,   // Giảm sâu 4 - 7%: Vùng tích lũy ưu tiên
  deepOversold // Bán tháo quá đà > 7% hoặc RSI < 30: Cơ hội vàng bắt đáy
}

/// Dữ liệu phát hiện nhịp giảm và gợi ý ngân sách mua thêm (Dip-Buying Radar)
@immutable
class DipSignal {
  final bool isDip;
  final DipSeverity severity;
  final double currentPrice;
  final double peakPrice30d;
  final double drawdownPercent;    // % giảm từ đỉnh 30 ngày (âm)
  final double rsi14;              // Chỉ số RSI 14 chu kỳ (0 - 100)
  final double ema20;              // Đường trung bình động 20 ngày
  final double extraBudgetMultiplier; // Hệ số tăng ngân sách (1.0x, 1.25x, 1.5x)
  final double suggestedBuyVnd;    // Số tiền khuyến nghị mua theo nhịp giảm này
  final String title;
  final String rationale;
  final DateTime detectedAt;

  const DipSignal({
    required this.isDip,
    required this.severity,
    required this.currentPrice,
    required this.peakPrice30d,
    required this.drawdownPercent,
    required this.rsi14,
    required this.ema20,
    required this.extraBudgetMultiplier,
    required this.suggestedBuyVnd,
    required this.title,
    required this.rationale,
    required this.detectedAt,
  });

  /// Màu sắc đại diện cho mức độ bắt đáy
  Color get severityColor {
    switch (severity) {
      case DipSeverity.none:
        return AurumColors.textMuted;
      case DipSeverity.mildDip:
        return AurumColors.sapphire;
      case DipSeverity.strongDip:
        return AurumColors.gold;
      case DipSeverity.deepOversold:
        return AurumColors.emerald;
    }
  }

  /// Tiêu đề trạng thái
  String get severityLabel {
    switch (severity) {
      case DipSeverity.none:
        return 'Đang đi ngang / Biến động bình thường';
      case DipSeverity.mildDip:
        return 'Nhịp chỉnh nhẹ (${drawdownPercent.toStringAsFixed(1)}%) — Gom thêm';
      case DipSeverity.strongDip:
        return 'Chiết khấu sâu (${drawdownPercent.toStringAsFixed(1)}%) — Vùng mua đẹp';
      case DipSeverity.deepOversold:
        return 'BẮT ĐÁY QUÁ BÁN (${drawdownPercent.toStringAsFixed(1)}%) — Kích hoạt vốn';
    }
  }
}
