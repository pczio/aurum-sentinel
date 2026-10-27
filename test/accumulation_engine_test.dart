import 'package:flutter_test/flutter_test.dart';
import 'package:aurumsentinel_app/core/constants/historical_data_constants.dart';
import 'package:aurumsentinel_app/domain/engines/accumulation_engine.dart';
import 'package:aurumsentinel_app/domain/engines/gold_price_curve.dart';

void main() {
  group('AccumulationEngine Unit Tests', () {
    late GoldPriceCurve curve;
    late AccumulationEngine engine;

    setUp(() {
      curve = GoldPriceCurve(HistoricalDataConstants.defaultHistoricalPrices);
      engine = AccumulationEngine(
        monthlyIncome: 15000000.0, // 15 triệu VNĐ
        levelsPct: [10, 15, 20, 25, 30],
      );
    });

    test('Mô phỏng lịch sử 2006 đến 2026 tính đúng số chỉ và lãi suất kép', () {
      final results = engine.simulateHistorical(
        curve: curve,
        startYear: 2006,
        endYear: 2026,
        endMonth: 9,
      );

      expect(results.length, 5);

      // Kiểm tra mức 20% (trích 3 triệu/tháng)
      final res20 = results.firstWhere((r) => r.levelPct == 20);
      expect(res20.points.isNotEmpty, true);

      // Tổng số chỉ tích lũy phải xấp xỉ ~210 chỉ vàng
      expect(res20.totalChi, greaterThan(180.0));
      expect(res20.totalChi, lessThan(250.0));

      // Lãi suất kép lịch sử phải dương và trên 250%
      expect(res20.gainPct, greaterThan(250.0));

      // Tổng vốn bỏ ra phải bằng số tháng * 3 triệu
      final expectedMonths = (2025 - 2006 + 1) * 12 + 9;
      expect(res20.totalInvested, equals(expectedMonths * 3000000.0));
    });

    test('Mô phỏng tương lai 10 năm với CAGR 12%/năm', () {
      final futureResults = engine.simulateFuture(
        currentPrice: 14880000.0,
        years: 10,
        annualCagrPct: 12.0,
      );

      expect(futureResults.length, 5);

      final fut20 = futureResults.firstWhere((r) => r.levelPct == 20);
      expect(fut20.points.length, 120); // 10 năm = 120 tháng

      // Vốn đầu tư 10 năm = 120 * 3 triệu = 360 triệu
      expect(fut20.totalInvested, equals(360000000.0));

      // Giá trị tài sản tương lai phải vượt trội nhờ lãi kép
      expect(fut20.totalValue, greaterThan(600000000.0));
      expect(fut20.gainPct, greaterThan(60.0));
    });

    test('Tính đơn điệu: mức % cao hơn thì số chỉ và giá trị luôn lớn hơn', () {
      final results = engine.simulateHistorical(
        curve: curve,
        startYear: 2015,
        endYear: 2025,
      );

      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].totalChi, lessThan(results[i + 1].totalChi));
        expect(results[i].totalValue, lessThan(results[i + 1].totalValue));
        expect(results[i].totalInvested, lessThan(results[i + 1].totalInvested));
      }
    });
  });
}
