import '../models/arbitrage_result.dart';

/// Cỗ máy định lượng SJC Arbitrage Spread Index (ASI)
class ArbitrageEngine {
  ArbitrageEngine._();

  /// Tính toán chỉ số ASI theo công thức định lượng gốc:
  /// ASI = SJC - (XAU_Spot * USD/VND / 31.1035 * 37.5 + Fee)
  /// Trong đó 37.5 / 31.1035 = 1.205653 oz/lượng.
  static ArbitrageResult calculateAsi({
    required double xauUsd,
    required double usdVnd,
    required double sjcSellPrice,
    double taxAndFee = 0.0,
    double safeThreshold = 5000000.0,
    double warningThreshold = 12000000.0,
  }) {
    // Giá thế giới quy đổi ra VNĐ / lượng:
    final double worldPerLuong = xauUsd * (usdVnd / 31.1034768) * 37.5;
    final double fairValueWithFee = worldPerLuong + taxAndFee;
    final double asi = sjcSellPrice - fairValueWithFee;

    final ArbitrageZone zone;
    final String title;
    final String description;
    final String suggestedAction;

    if (asi <= safeThreshold) {
      zone = ArbitrageZone.safe;
      title = 'Vùng Tích Sản Vật Chất An Toàn';
      description =
          'Chênh lệch giữa giá vàng SJC và giá thế giới ở mức thấp lý tưởng. Rủi ro thất thoát vốn do co hẹp biên độ premium là tối thiểu.';
      suggestedAction =
          'Thích hợp mua tích lũy vàng miếng SJC hoặc nhẫn trơn 9999 cho mục tiêu nắm giữ dài hạn.';
    } else if (asi <= warningThreshold) {
      zone = ArbitrageZone.moderate;
      title = 'Chênh Lệch Vừa Phải (Trung Tính)';
      description =
          'Mức chênh lệch nằm trong biên độ dao động thông thường của thị trường nội địa do giới hạn nguồn cung vàng nguyên liệu.';
      suggestedAction =
          'Ưu tiên tích lũy vàng nhẫn tròn trơn 9999 của các thương hiệu lớn (PNJ, DOJI, BTMC) vì biên độ chênh lệch thấp hơn SJC.';
    } else {
      zone = ArbitrageZone.danger;
      title = 'Chênh Lệch Quá Cao — Rủi Ro Premium';
      description =
          'Giá SJC trong nước đang đắt hơn giá vàng quốc tế quá lớn. Khi thị trường hạ nhiệt hoặc có chính sách bình ổn, bạn sẽ gánh khoản chênh lệch này.';
      suggestedAction =
          'Tuyệt đối không fomo mua đuổi giá đỉnh. Kiên nhẫn chờ nhịp điều chỉnh hoặc chỉ mua số lượng nhỏ phòng thủ.';
    }

    return ArbitrageResult(
      asi: asi,
      worldConvertedPerLuong: worldPerLuong,
      domesticSjcPrice: sjcSellPrice,
      taxAndFee: taxAndFee,
      zone: zone,
      title: title,
      description: description,
      suggestedAction: suggestedAction,
    );
  }
}
