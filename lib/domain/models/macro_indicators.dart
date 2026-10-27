import 'package:flutter/material.dart';
import '../../core/constants/aurum_colors.dart';

enum ValuationState {
  undervalued, // Giá thị trường thấp hơn giá trị hợp lý (Rất hấp dẫn)
  fair,        // Định giá sát thực tế
  overvalued,  // Định giá cao hơn vĩ mô (Cần thận trọng)
}

/// Dữ liệu biến số vĩ mô thế giới & Mô hình định giá vàng XAU
@immutable
class MacroIndicators {
  final double tips10Y;           // Lợi suất thực 10 năm Mỹ DFII10 (%)
  final double dxy;               // Chỉ số US Dollar Index
  final double cbNetBuyTons;      // Mua ròng NHTW thế giới (tấn/tháng)
  final double fairValueXau;      // Giá trị hợp lý vĩ mô P* (USD/oz)
  final double marketPriceXau;    // Giá thị trường thực tế XAU/USD
  final DateTime updatedAt;

  const MacroIndicators({
    required this.tips10Y,
    required this.dxy,
    required this.cbNetBuyTons,
    required this.fairValueXau,
    required this.marketPriceXau,
    required this.updatedAt,
  });

  /// Độ lệch định giá (%) = (Thị trường - Hợp lý) / Hợp lý * 100
  double get gapPercent {
    return fairValueXau > 0 ? ((marketPriceXau - fairValueXau) / fairValueXau) * 100.0 : 0.0;
  }

  /// Trạng thái định giá
  ValuationState get state {
    if (gapPercent < -5.0) return ValuationState.undervalued;
    if (gapPercent > 8.0) return ValuationState.overvalued;
    return ValuationState.fair;
  }

  /// Màu sắc trạng thái
  Color get stateColor {
    switch (state) {
      case ValuationState.undervalued:
        return AurumColors.emerald;
      case ValuationState.fair:
        return AurumColors.gold;
      case ValuationState.overvalued:
        return AurumColors.ruby;
    }
  }

  /// Nhãn trạng thái tiếng Việt
  String get stateLabel {
    switch (state) {
      case ValuationState.undervalued:
        return 'Định giá thấp (${gapPercent.toStringAsFixed(1)}%) — Vùng gom';
      case ValuationState.fair:
        return 'Định giá hợp lý (${gapPercent >= 0 ? '+' : ''}${gapPercent.toStringAsFixed(1)}%)';
      case ValuationState.overvalued:
        return 'Định giá cao (+${gapPercent.toStringAsFixed(1)}%) — Cần thận trọng';
    }
  }
}
