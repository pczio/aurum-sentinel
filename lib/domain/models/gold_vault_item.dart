import 'package:flutter/foundation.dart';
import '../../core/constants/market_constants.dart';

enum GoldBrandType {
  sjc,
  pnj,
  doji,
  baoTinMinhChau,
  miHong,
  other,
}

enum GoldProductType {
  ring9999,      // Nhẫn trơn tròn ép vỉ 999.9
  barSjc,        // Vàng miếng SJC 1 lượng
  miniBar,       // Vàng miếng mini 1 chỉ / 2 phân
  jewelry,       // Trang sức vàng ta
  other,
}

enum WeightUnit {
  chi,   // Chỉ (3.75g)
  phan,  // Phân (0.375g)
  luong, // Lượng / Cây (37.5g)
  gram,  // Gram
}

extension WeightUnitExtension on WeightUnit {
  String get label {
    switch (this) {
      case WeightUnit.chi:
        return 'chỉ';
      case WeightUnit.phan:
        return 'phân';
      case WeightUnit.luong:
        return 'lượng';
      case WeightUnit.gram:
        return 'gram';
    }
  }

  String get uppercaseLabel {
    switch (this) {
      case WeightUnit.chi:
        return 'CHỈ';
      case WeightUnit.phan:
        return 'PHÂN';
      case WeightUnit.luong:
        return 'LƯỢNG';
      case WeightUnit.gram:
        return 'GRAM';
    }
  }
}

/// Một món tài sản vàng trong két cá nhân
@immutable
class GoldVaultItem {
  final String id;
  final String title;
  final GoldBrandType brand;
  final GoldProductType productType;
  final WeightUnit unit;
  final double quantity;           // Số lượng theo đơn vị unit
  final double buyPricePerUnit;    // Giá mua thực tế mỗi đơn vị (VND)
  final DateTime purchaseDate;
  final String storageNote;        // Nơi cất giữ ("Két sắt nhà", "Ngân hàng")

  const GoldVaultItem({
    required this.id,
    required this.title,
    required this.brand,
    required this.productType,
    required this.unit,
    required this.quantity,
    required this.buyPricePerUnit,
    required this.purchaseDate,
    this.storageNote = '',
  });

  /// Quy đổi toàn bộ số lượng ra số Chỉ vàng chuẩn
  double get totalChi {
    switch (unit) {
      case WeightUnit.chi:
        return quantity;
      case WeightUnit.phan:
        return quantity / MarketConstants.phanPerChi;
      case WeightUnit.luong:
        return quantity * MarketConstants.chiPerLuong;
      case WeightUnit.gram:
        return quantity / MarketConstants.gramPerChi;
    }
  }

  /// Tổng số tiền vốn đã bỏ ra để mua món này (VND)
  double get totalInvested => quantity * buyPricePerUnit;

  /// Giá vốn bình quân trên mỗi chỉ (VND/chỉ)
  double get costPerChi => totalChi > 0 ? totalInvested / totalChi : 0.0;

  /// Định giá thị trường hiện tại dựa trên giá vàng nhẫn/SJC hiện hành
  double currentMarketValue({
    required double currentRingPricePerChi,
    required double currentSjcPricePerLuong,
  }) {
    if (productType == GoldProductType.barSjc) {
      final double luong = totalChi / MarketConstants.chiPerLuong;
      return luong * currentSjcPricePerLuong;
    }
    return totalChi * currentRingPricePerChi;
  }

  /// Lãi/Lỗ ròng (VND)
  double netProfit({
    required double currentRingPricePerChi,
    required double currentSjcPricePerLuong,
  }) {
    return currentMarketValue(
          currentRingPricePerChi: currentRingPricePerChi,
          currentSjcPricePerLuong: currentSjcPricePerLuong,
        ) -
        totalInvested;
  }

  /// Tỷ suất sinh lời ROI (%)
  double roiPercent({
    required double currentRingPricePerChi,
    required double currentSjcPricePerLuong,
  }) {
    if (totalInvested <= 0) return 0.0;
    return (netProfit(
              currentRingPricePerChi: currentRingPricePerChi,
              currentSjcPricePerLuong: currentSjcPricePerLuong,
            ) /
            totalInvested) *
        100.0;
  }

  /// Tên thương hiệu hiển thị
  String get brandDisplayName {
    switch (brand) {
      case GoldBrandType.sjc:
        return 'SJC';
      case GoldBrandType.pnj:
        return 'PNJ';
      case GoldBrandType.doji:
        return 'DOJI';
      case GoldBrandType.baoTinMinhChau:
        return 'Bảo Tín Minh Châu';
      case GoldBrandType.miHong:
        return 'Mi Hồng';
      case GoldBrandType.other:
        return 'Tiệm Vàng Khác';
    }
  }

  /// Tên loại sản phẩm
  String get productDisplayName {
    switch (productType) {
      case GoldProductType.ring9999:
        return 'Nhẫn trơn 999.9';
      case GoldProductType.barSjc:
        return 'Vàng miếng SJC';
      case GoldProductType.miniBar:
        return 'Miếng mini ép vỉ';
      case GoldProductType.jewelry:
        return 'Trang sức vàng ta';
      case GoldProductType.other:
        return 'Vàng vật chất khác';
    }
  }

  /// Tên đơn vị hiển thị
  String get unitDisplayName => unit.label;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'brand': brand.index,
        'productType': productType.index,
        'unit': unit.index,
        'quantity': quantity,
        'buyPricePerUnit': buyPricePerUnit,
        'purchaseDate': purchaseDate.toIso8601String(),
        'storageNote': storageNote,
      };

  factory GoldVaultItem.fromJson(Map<String, dynamic> json) => GoldVaultItem(
        id: json['id'] as String,
        title: json['title'] as String,
        brand: GoldBrandType.values[json['brand'] as int],
        productType: GoldProductType.values[json['productType'] as int],
        unit: WeightUnit.values[json['unit'] as int],
        quantity: (json['quantity'] as num).toDouble(),
        buyPricePerUnit: (json['buyPricePerUnit'] as num).toDouble(),
        purchaseDate: DateTime.parse(json['purchaseDate'] as String),
        storageNote: json['storageNote'] as String? ?? '',
      );
}

/// Báo cáo tổng hợp két vàng
@immutable
class VaultSummary {
  final double totalChi;
  final double totalInvested;
  final double currentMarketValue;
  final double netProfit;
  final double roiPercent;
  final int totalItems;

  const VaultSummary({
    required this.totalChi,
    required this.totalInvested,
    required this.currentMarketValue,
    required this.netProfit,
    required this.roiPercent,
    required this.totalItems,
  });

  double get totalLuong => totalChi / MarketConstants.chiPerLuong;
}
