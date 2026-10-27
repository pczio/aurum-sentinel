import 'dart:math' as math;

/// Kết quả phân tích mô phỏng ngẫu nhiên Monte Carlo
class MonteCarloSimulationResult {
  final int simulationRuns;
  final int years;
  final double p10Wealth; // Kịch bản 10% xấu nhất (Vùng phòng thủ)
  final double p50Wealth; // Kịch bản trung vị (Kỳ vọng phổ biến)
  final double p90Wealth; // Kịch bản 10% bùng nổ tốt nhất
  final double probabilityOfProfit; // Xác suất sinh lời dương (%)
  final List<double> medianPath; // Đường đi trung vị qua từng năm

  const MonteCarloSimulationResult({
    required this.simulationRuns,
    required this.years,
    required this.p10Wealth,
    required this.p50Wealth,
    required this.p90Wealth,
    required this.probabilityOfProfit,
    required this.medianPath,
  });
}

/// Động cơ mô phỏng ngẫu nhiên Monte Carlo (Geometric Brownian Motion) cho danh mục tích sản vàng
class MonteCarloEngine {
  MonteCarloEngine._();

  /// Chạy mô phỏng Monte Carlo đa kịch bản (1.000 chu kỳ)
  static MonteCarloSimulationResult runSimulation({
    required double monthlyIncome,
    required int levelPct,
    required double startPrice,
    required int years,
    double expectedAnnualReturn = 0.10, // Lợi suất kỳ vọng 10%/năm
    double annualVolatility = 0.16,     // Độ biến động lịch sử của vàng 16%/năm
    int numRuns = 1000,
  }) {
    final math.Random random = math.Random(42); // Hạt giống cố định để kết quả ổn định
    final int totalMonths = years * 12;
    final double monthlyDeposit = monthlyIncome * (levelPct / 100.0);
    final double dt = 1.0 / 12.0;
    final double drift = (expectedAnnualReturn - 0.5 * annualVolatility * annualVolatility) * dt;
    final double volSqrtDt = annualVolatility * math.sqrt(dt);

    final List<double> finalWealths = [];
    final List<List<double>> paths = List.generate(numRuns, (_) => []);

    for (int r = 0; r < numRuns; r++) {
      double price = startPrice;
      double cumChi = 0.0;
      for (int m = 1; m <= totalMonths; m++) {
        // Tạo biến ngẫu nhiên phân phối chuẩn bằng Box-Muller transform
        final double u1 = math.max(1e-10, random.nextDouble());
        final double u2 = random.nextDouble();
        final double z = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);

        // Chuyển động Brown hình học Geometric Brownian Motion (GBM)
        price *= math.exp(drift + volSqrtDt * z);

        final double chiBought = monthlyDeposit / price;
        cumChi += chiBought;

        if (m % 12 == 0) {
          paths[r].add(cumChi * price);
        }
      }

      final double finalVal = cumChi * price;
      finalWealths.add(finalVal);
    }

    finalWealths.sort();

    final int p10Index = (numRuns * 0.10).floor();
    final int p50Index = (numRuns * 0.50).floor();
    final int p90Index = (numRuns * 0.90).floor();

    final double totalInvested = monthlyDeposit * totalMonths;
    int profitRuns = 0;
    for (final val in finalWealths) {
      if (val >= totalInvested) profitRuns++;
    }

    final double probProfit = (profitRuns / numRuns) * 100.0;

    // Tính đường đi trung vị qua từng năm
    final List<double> medianPath = [];
    for (int y = 0; y < years; y++) {
      final List<double> yearValues = [for (int r = 0; r < numRuns; r++) paths[r][y]];
      yearValues.sort();
      medianPath.add(yearValues[p50Index]);
    }

    return MonteCarloSimulationResult(
      simulationRuns: numRuns,
      years: years,
      p10Wealth: finalWealths[p10Index],
      p50Wealth: finalWealths[p50Index],
      p90Wealth: finalWealths[p90Index],
      probabilityOfProfit: probProfit,
      medianPath: medianPath,
    );
  }
}
