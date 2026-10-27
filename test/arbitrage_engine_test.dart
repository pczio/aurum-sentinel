import 'package:flutter_test/flutter_test.dart';
import 'package:aurumsentinel_app/domain/engines/arbitrage_engine.dart';
import 'package:aurumsentinel_app/domain/models/arbitrage_result.dart';

void main() {
  group('ArbitrageEngine Unit Tests', () {
    test('Tính toán đúng chỉ số ASI và phân vùng an toàn', () {
      // XAU = 4450 USD/oz, USD/VND = 26200
      // Thế giới quy đổi = 4450 * (26200 / 31.1034768) * 37.5 = ~140.566.800 đ/lượng
      // SJC = 145.000.000 đ/lượng -> ASI = ~4.433.200 đ/lượng (<= 5 triệu -> Safe)
      final result = ArbitrageEngine.calculateAsi(
        xauUsd: 4450.0,
        usdVnd: 26200.0,
        sjcSellPrice: 145000000.0,
        taxAndFee: 0.0,
      );

      expect(result.worldConvertedPerLuong, greaterThan(140000000.0));
      expect(result.worldConvertedPerLuong, lessThan(141000000.0));
      expect(result.asi, lessThanOrEqualTo(5000000.0));
      expect(result.zone, equals(ArbitrageZone.safe));
    });

    test('Phát hiện vùng cảnh báo rủi ro cao khi chênh lệch vượt 12 triệu', () {
      // SJC = 158.000.000 đ/lượng -> ASI > 17 triệu
      final result = ArbitrageEngine.calculateAsi(
        xauUsd: 4450.0,
        usdVnd: 26200.0,
        sjcSellPrice: 158000000.0,
        taxAndFee: 0.0,
      );

      expect(result.asi, greaterThan(12000000.0));
      expect(result.zone, equals(ArbitrageZone.danger));
      expect(result.suggestedAction.contains('không'), true);
    });
  });
}
