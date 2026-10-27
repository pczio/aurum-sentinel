import 'dart:math' as math;
import '../models/accumulation_models.dart';
import '../models/gold_scenario.dart';
import 'gold_price_curve.dart';

/// Cỗ máy định lượng Tích Sản Lãi Kép Vàng (Compound Accumulation Engine)
/// Hiện thực hóa triết lý "Nhận lương là mua vàng":
/// Mỗi tháng trích một khoản % lương cố định mua vàng nhẫn. Khi giá rẻ mua được nhiều chỉ,
/// khi giá đắt mua được ít chỉ hơn (DCA chuẩn xác). Toàn bộ lượng vàng tích lũy được định giá
/// lại theo giá thị trường tăng trưởng, tạo hiệu ứng lãi kép vượt trội.
class AccumulationEngine {
  final double monthlyIncome;
  final List<int> levelsPct;

  AccumulationEngine({
    required this.monthlyIncome,
    required this.levelsPct,
  });

  /// Mô phỏng lịch sử (Retrospective Simulation): Từ năm bắt đầu đến hiện tại
  List<SimulationResult> simulateHistorical({
    required GoldPriceCurve curve,
    required int startYear,
    required int endYear,
    int endMonth = 12,
  }) {
    final List<SimulationResult> results = [];

    for (final pct in levelsPct) {
      double cumChi = 0.0;
      double cumInvested = 0.0;
      final List<MonthlyPoint> points = [];
      int sequentialIndex = 0;

      for (int year = startYear; year <= endYear; year++) {
        final int lastMonth = (year == endYear) ? endMonth : 12;
        for (int month = 1; month <= lastMonth; month++) {
          final double price = curve.priceAt(year, month);
          final double monthlyBuyVnd = monthlyIncome * (pct / 100.0);
          final double chi = price > 0 ? (monthlyBuyVnd / price) : 0.0;

          cumChi += chi;
          cumInvested += monthlyBuyVnd;
          final double cumValue = cumChi * price;

          points.add(
            MonthlyPoint(
              label: '$year-${month.toString().padLeft(2, '0')}',
              monthIndex: sequentialIndex++,
              year: year,
              month: month,
              chiBought: chi,
              cumulativeChi: cumChi,
              pricePerChi: price,
              cumulativeValue: cumValue,
              cumulativeInvested: cumInvested,
            ),
          );
        }
      }

      results.add(SimulationResult(levelPct: pct, points: points));
    }

    return results;
  }

  /// Mô phỏng tương lai (Prospective Compounding Simulation)
  /// Dự phóng tài sản tích lũy qua N năm với tốc độ tăng trưởng giá vàng kỳ vọng CAGR
  List<SimulationResult> simulateFuture({
    required double currentPrice,
    required int years,
    required double annualCagrPct,
  }) {
    // Tăng trưởng giá theo tháng = (1 + CAGR)^(1/12) - 1
    final double monthlyGrowth = math.pow(1.0 + annualCagrPct / 100.0, 1.0 / 12.0) - 1.0;
    final int totalMonths = years * 12;
    final List<SimulationResult> results = [];

    for (final pct in levelsPct) {
      double cumChi = 0.0;
      double cumInvested = 0.0;
      double price = currentPrice;
      final List<MonthlyPoint> points = [];

      for (int m = 1; m <= totalMonths; m++) {
        final double monthlyBuyVnd = monthlyIncome * (pct / 100.0);
        final double chi = price > 0 ? (monthlyBuyVnd / price) : 0.0;

        cumChi += chi;
        cumInvested += monthlyBuyVnd;
        final double cumValue = cumChi * price;

        final int yearOffset = (m - 1) ~/ 12 + 1;
        final int monthInYear = ((m - 1) % 12) + 1;

        points.add(
          MonthlyPoint(
            label: 'T+$m (Năm $yearOffset.$monthInYear)',
            monthIndex: m - 1,
            year: DateTime.now().year + yearOffset - 1,
            month: monthInYear,
            chiBought: chi,
            cumulativeChi: cumChi,
            pricePerChi: price,
            cumulativeValue: cumValue,
            cumulativeInvested: cumInvested,
          ),
        );

        // Giá vàng tăng trưởng sang tháng tiếp theo
        price *= (1.0 + monthlyGrowth);
      }

      results.add(SimulationResult(levelPct: pct, points: points));
    }

    return results;
  }

  /// Mô phỏng tương lai với một mức tích lũy cố định trên nhiều kịch bản (Bearish, Base, Bullish)
  Map<String, ScenarioSimulationResult> simulateFutureScenarios({
    required double currentPrice,
    required int years,
    required int levelPct,
    required List<GoldScenario> scenarios,
  }) {
    final singleEngine = AccumulationEngine(
      monthlyIncome: monthlyIncome,
      levelsPct: [levelPct],
    );

    final Map<String, ScenarioSimulationResult> output = {};

    for (final sc in scenarios) {
      final sim = singleEngine.simulateFuture(
        currentPrice: currentPrice,
        years: years,
        annualCagrPct: sc.cagrPct,
      ).first;

      output[sc.id] = ScenarioSimulationResult(
        scenario: sc,
        simulation: sim,
      );
    }

    return output;
  }
}
