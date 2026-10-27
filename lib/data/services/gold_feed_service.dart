import 'dart:math' as math;
import '../../domain/models/gold_price_snapshot.dart';

/// Dịch vụ cấp phát luồng dữ liệu giá vàng thời gian thực (Market Data Feed)
class GoldFeedService {
  GoldPriceSnapshot _currentSnapshot = GoldPriceSnapshot.defaultSnapshot();
  final math.Random _random = math.Random();

  GoldPriceSnapshot get currentSnapshot => _currentSnapshot;

  /// Lấy danh sách giá các thương hiệu vàng lớn tại Việt Nam
  List<GoldBrandPrice> fetchBrandPrices() {
    final now = DateTime.now();
    final double sjcSell = _currentSnapshot.sjcSellPerLuong;
    final double sjcBuy = _currentSnapshot.sjcBuyPerLuong;
    final double ringSell = _currentSnapshot.ringSellPerChi;
    final double ringBuy = _currentSnapshot.ringBuyPerChi;

    return [
      GoldBrandPrice(
        brandName: 'SJC TP.HCM',
        productName: 'Vàng miếng SJC 1 Lượng (99.99%)',
        buyPrice: sjcBuy,
        sellPrice: sjcSell,
        unit: 'VND / lượng',
        change24h: 0.85,
        updatedAt: now,
      ),
      GoldBrandPrice(
        brandName: 'DOJI',
        productName: 'Nhẫn Tròn Trơn Hưng Thịnh Vượng 9999',
        buyPrice: ringBuy - 20000,
        sellPrice: ringSell - 10000,
        unit: 'VND / chỉ',
        change24h: 1.20,
        updatedAt: now,
      ),
      GoldBrandPrice(
        brandName: 'PNJ',
        productName: 'Nhẫn Trơn PNJ 999.9',
        buyPrice: ringBuy,
        sellPrice: ringSell,
        unit: 'VND / chỉ',
        change24h: 1.15,
        updatedAt: now,
      ),
      GoldBrandPrice(
        brandName: 'Bảo Tín Minh Châu',
        productName: 'Nhẫn Tròn Trơn Rồng Thăng Long',
        buyPrice: ringBuy + 30000,
        sellPrice: ringSell + 20000,
        unit: 'VND / chỉ',
        change24h: 1.35,
        updatedAt: now,
      ),
      GoldBrandPrice(
        brandName: 'Mi Hồng',
        productName: 'Vàng 999 Mi Hồng',
        buyPrice: ringBuy - 50000,
        sellPrice: ringSell - 30000,
        unit: 'VND / chỉ',
        change24h: 0.95,
        updatedAt: now,
      ),
    ];
  }

  /// Sinh chuỗi 30 phiên giá gần nhất để tính toán RSI & EMA cho Radar bắt đáy
  List<double> fetchRecent30DaysPrices() {
    final double basePrice = _currentSnapshot.ringSellPerChi;
    final List<double> prices = [];
    double current = basePrice * 0.96; // 30 ngày trước

    for (int i = 0; i < 30; i++) {
      // Mô phỏng chuỗi giá thực tế có nhịp tăng và nhịp chỉnh
      final double drift = 0.0015;
      final double shock = (_random.nextDouble() - 0.48) * 0.012;
      current = current * (1.0 + drift + shock);
      prices.add(current);
    }

    // Đảm bảo phiên cuối cùng khớp với giá hiện tại
    prices[prices.length - 1] = basePrice;
    return prices;
  }

  /// Cập nhật giá thủ công từ người dùng
  void updateManualPrices({
    required double xauUsd,
    required double usdVnd,
    required double sjcSellPerLuong,
    required double ringSellPerChi,
  }) {
    _currentSnapshot = _currentSnapshot.copyWith(
      xauUsd: xauUsd,
      usdVnd: usdVnd,
      sjcSellPerLuong: sjcSellPerLuong,
      sjcBuyPerLuong: sjcSellPerLuong - 2500000,
      ringSellPerChi: ringSellPerChi,
      ringBuyPerChi: ringSellPerChi - 260000,
      timestamp: DateTime.now(),
    );
  }

  /// Sinh biến động ngẫu nhiên vi mô (Tick simulation)
  GoldPriceSnapshot tickSimulate() {
    final double deltaPct = (_random.nextDouble() - 0.49) * 0.003;
    final double newXau = _currentSnapshot.xauUsd * (1.0 + deltaPct);
    final double newRing = _currentSnapshot.ringSellPerChi * (1.0 + deltaPct * 0.8);

    _currentSnapshot = _currentSnapshot.copyWith(
      xauUsd: double.parse(newXau.toStringAsFixed(1)),
      ringSellPerChi: double.parse(newRing.toStringAsFixed(0)),
      timestamp: DateTime.now(),
    );

    return _currentSnapshot;
  }
}
