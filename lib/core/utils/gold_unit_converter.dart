import '../constants/market_constants.dart';

/// Bộ chuyển đổi và định dạng đơn vị vàng vật chất Việt Nam & Quốc tế
class GoldUnitConverter {
  GoldUnitConverter._();

  /// Chuyển đổi Chỉ sang Lượng (Cây)
  static double chiToLuong(double chi) => chi / MarketConstants.chiPerLuong;

  /// Chuyển đổi Lượng sang Chỉ
  static double luongToChi(double luong) => luong * MarketConstants.chiPerLuong;

  /// Chuyển đổi Chỉ sang Phân
  static double chiToPhan(double chi) => chi * MarketConstants.phanPerChi;

  /// Chuyển đổi Phân sang Chỉ
  static double phanToChi(double phan) => phan / MarketConstants.phanPerChi;

  /// Chuyển đổi Gram sang Chỉ
  static double gramToChi(double grams) => grams / MarketConstants.gramPerChi;

  /// Chuyển đổi Chỉ sang Gram
  static double chiToGrams(double chi) => chi * MarketConstants.gramPerChi;

  /// Chuyển đổi Troy Oz sang Chỉ
  static double ozToChi(double oz) => (oz * MarketConstants.gramPerTroyOz) / MarketConstants.gramPerChi;

  /// Chuyển đổi Chỉ sang Troy Oz
  static double chiToOz(double chi) => chiToGrams(chi) / MarketConstants.gramPerTroyOz;

  /// Chuyển đổi Troy Oz sang Lượng
  static double ozToLuong(double oz) => oz / MarketConstants.ozPerLuong;

  /// Chuyển đổi Lượng sang Troy Oz
  static double luongToOz(double luong) => luong * MarketConstants.ozPerLuong;

  /// Định dạng số chỉ vàng: "210,452 chỉ"
  static String fmtChi(double chi, {int decimals = 3}) {
    return '${chi.toStringAsFixed(decimals)} chỉ';
  }

  /// Định dạng số lượng vàng: "21,045 lượng"
  static String fmtLuong(double luong, {int decimals = 3}) {
    return '${luong.toStringAsFixed(decimals)} lượng';
  }

  /// Phân rã số chỉ thành dạng truyền thống: ví dụ 25.3 chỉ -> "2 lượng 5 chỉ 3 phân"
  static String fmtTraditional(double totalChi) {
    if (totalChi <= 0) return '0 chỉ';
    
    final int luong = (totalChi / MarketConstants.chiPerLuong).floor();
    final double remainingChi = totalChi - (luong * MarketConstants.chiPerLuong);
    final int chi = remainingChi.floor();
    final double remainingPhan = (remainingChi - chi) * MarketConstants.phanPerChi;
    final int phan = remainingPhan.round();

    final buffer = StringBuffer();
    if (luong > 0) buffer.write('$luong lượng ');
    if (chi > 0 || (luong > 0 && phan > 0)) buffer.write('$chi chỉ ');
    if (phan > 0 || buffer.isEmpty) buffer.write('$phan phân');

    return buffer.toString().trim();
  }
}
