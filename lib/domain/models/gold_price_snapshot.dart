import 'package:flutter/foundation.dart';

/// Ảnh chụp giá thị trường vàng tại một thời điểm
@immutable
class GoldPriceSnapshot {
  final double xauUsd;            // Giá thế giới XAU/USD (USD/oz)
  final double xauUsdChange24h;   // % biến động 24h
  final double xauUsdHigh24h;     // Giá cao nhất 24h
  final double xauUsdLow24h;      // Giá thấp nhất 24h
  final double usdVnd;            // Tỷ giá USD/VND
  final double sjcSellPerLuong;   // Giá SJC bán ra (VND/lượng)
  final double sjcBuyPerLuong;    // Giá SJC mua vào (VND/lượng)
  final double ringSellPerChi;    // Giá nhẫn 9999 bán ra (VND/chỉ)
  final double ringBuyPerChi;     // Giá nhẫn 9999 mua vào (VND/chỉ)
  final DateTime timestamp;

  const GoldPriceSnapshot({
    required this.xauUsd,
    required this.xauUsdChange24h,
    required this.xauUsdHigh24h,
    required this.xauUsdLow24h,
    required this.usdVnd,
    required this.sjcSellPerLuong,
    required this.sjcBuyPerLuong,
    required this.ringSellPerChi,
    required this.ringBuyPerChi,
    required this.timestamp,
  });

  /// Giá vàng thế giới quy đổi ra VNĐ / lượng (chưa thuế phí):
  /// XAU_Spot * USD/VND * 1.205653
  double get worldConvertedPerLuong {
    return xauUsd * usdVnd * 1.205653;
  }

  /// Giá vàng thế giới quy đổi ra VNĐ / chỉ:
  double get worldConvertedPerChi {
    return worldConvertedPerLuong / 10.0;
  }

  /// Chênh lệch SJC bán ra vs Thế giới (VND/lượng)
  double get sjcWorldSpread {
    return sjcSellPerLuong - worldConvertedPerLuong;
  }

  /// Chênh lệch Nhẫn 9999 bán ra vs Thế giới (VND/chỉ)
  double get ringWorldSpread {
    return ringSellPerChi - worldConvertedPerChi;
  }

  /// Bản sao với các trường thay đổi
  GoldPriceSnapshot copyWith({
    double? xauUsd,
    double? xauUsdChange24h,
    double? xauUsdHigh24h,
    double? xauUsdLow24h,
    double? usdVnd,
    double? sjcSellPerLuong,
    double? sjcBuyPerLuong,
    double? ringSellPerChi,
    double? ringBuyPerChi,
    DateTime? timestamp,
  }) {
    return GoldPriceSnapshot(
      xauUsd: xauUsd ?? this.xauUsd,
      xauUsdChange24h: xauUsdChange24h ?? this.xauUsdChange24h,
      xauUsdHigh24h: xauUsdHigh24h ?? this.xauUsdHigh24h,
      xauUsdLow24h: xauUsdLow24h ?? this.xauUsdLow24h,
      usdVnd: usdVnd ?? this.usdVnd,
      sjcSellPerLuong: sjcSellPerLuong ?? this.sjcSellPerLuong,
      sjcBuyPerLuong: sjcBuyPerLuong ?? this.sjcBuyPerLuong,
      ringSellPerChi: ringSellPerChi ?? this.ringSellPerChi,
      ringBuyPerChi: ringBuyPerChi ?? this.ringBuyPerChi,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Mặc định ban đầu
  factory GoldPriceSnapshot.defaultSnapshot() {
    return GoldPriceSnapshot(
      xauUsd: 4450.0,
      xauUsdChange24h: 1.42,
      xauUsdHigh24h: 4468.0,
      xauUsdLow24h: 4410.0,
      usdVnd: 26200.0,
      sjcSellPerLuong: 148000000.0,
      sjcBuyPerLuong: 145500000.0,
      ringSellPerChi: 14880000.0,
      ringBuyPerChi: 14620000.0,
      timestamp: DateTime.now(),
    );
  }
}

/// Dữ liệu giá vàng của từng thương hiệu cụ thể (SJC, DOJI, PNJ, Bảo Tín Minh Châu, Mi Hồng)
@immutable
class GoldBrandPrice {
  final String brandName;
  final String productName;
  final double buyPrice;          // VND
  final double sellPrice;         // VND
  final String unit;              // "VND/lượng" hoặc "VND/chỉ"
  final double change24h;         // %
  final DateTime updatedAt;

  const GoldBrandPrice({
    required this.brandName,
    required this.productName,
    required this.buyPrice,
    required this.sellPrice,
    required this.unit,
    required this.change24h,
    required this.updatedAt,
  });

  /// Chênh lệch Mua - Bán (Spread)
  double get spread => sellPrice - buyPrice;

  /// Tỷ lệ spread %
  double get spreadPercent => sellPrice > 0 ? (spread / sellPrice) * 100.0 : 0.0;
}
