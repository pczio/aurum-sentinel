import 'package:flutter/material.dart';
import '../../core/constants/aurum_colors.dart';

enum ArbitrageZone {
  safe,     // ASI <= 5 triệu: Vùng mua tích sản an toàn
  moderate, // 5 triệu < ASI <= 12 triệu: Vùng trung tính
  danger,   // ASI > 12 triệu: Vùng rủi ro cao, không mua đuổi
}

/// Kết quả định lượng chênh lệch SJC Arbitrage Spread Index (ASI)
@immutable
class ArbitrageResult {
  final double asi;                      // Giá trị ASI (VND/lượng)
  final double worldConvertedPerLuong;   // Giá thế giới quy đổi
  final double domesticSjcPrice;         // Giá SJC bán ra
  final double taxAndFee;                // Thuế phí ước tính
  final ArbitrageZone zone;
  final String title;
  final String description;
  final String suggestedAction;

  const ArbitrageResult({
    required this.asi,
    required this.worldConvertedPerLuong,
    required this.domesticSjcPrice,
    required this.taxAndFee,
    required this.zone,
    required this.title,
    required this.description,
    required this.suggestedAction,
  });

  /// Màu sắc đại diện cho trạng thái Arbitrage
  Color get statusColor {
    switch (zone) {
      case ArbitrageZone.safe:
        return AurumColors.emerald;
      case ArbitrageZone.moderate:
        return AurumColors.amber;
      case ArbitrageZone.danger:
        return AurumColors.ruby;
    }
  }

  /// Tỷ lệ chênh lệch so với giá vàng thế giới (%)
  double get premiumPercent {
    return worldConvertedPerLuong > 0 ? (asi / worldConvertedPerLuong) * 100.0 : 0.0;
  }
}
