import 'package:flutter_test/flutter_test.dart';
import 'package:aurumsentinel_app/domain/engines/dip_signal_engine.dart';
import 'package:aurumsentinel_app/domain/models/dip_signal_models.dart';

void main() {
  group('DipSignalEngine Unit Tests', () {
    test('Kích hoạt cảnh báo bắt đáy quá bán khi giá giảm sâu > 7%', () {
      // Giả lập chuỗi giá 30 ngày có đỉnh 16 triệu, hiện tại rớt xuống 14.5 triệu (giảm -9.3%)
      final List<double> prices = [
        for (int i = 0; i < 20; i++) 15500000.0 + i * 25000,
        16000000.0, // Đỉnh
        15600000.0,
        15200000.0,
        14800000.0,
        14500000.0, // Giá hiện tại
      ];

      final signal = DipSignalEngine.evaluateDip(
        recentPrices: prices,
        currentPrice: 14500000.0,
        regularMonthlyDcaBudget: 3000000.0,
      );

      expect(signal.isDip, true);
      expect(signal.severity, equals(DipSeverity.deepOversold));
      expect(signal.drawdownPercent, lessThan(-7.0));
      expect(signal.extraBudgetMultiplier, equals(1.5));
      expect(signal.suggestedBuyVnd, equals(4500000.0)); // 3 triệu * 1.5
    });

    test('Không kích hoạt bắt đáy khi thị trường đang ở đỉnh', () {
      final List<double> prices = [
        for (int i = 0; i < 25; i++) 14000000.0 + i * 40000,
        15000000.0, // Đỉnh hiện tại
      ];

      final signal = DipSignalEngine.evaluateDip(
        recentPrices: prices,
        currentPrice: 15000000.0,
        regularMonthlyDcaBudget: 3000000.0,
      );

      expect(signal.isDip, false);
      expect(signal.severity, equals(DipSeverity.none));
      expect(signal.extraBudgetMultiplier, equals(1.0));
      expect(signal.suggestedBuyVnd, equals(3000000.0));
    });
  });
}
