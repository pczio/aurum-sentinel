import 'package:flutter/foundation.dart';

/// Điểm dữ liệu hàng tháng trong chuỗi mô phỏng tích sản
@immutable
class MonthlyPoint {
  final String label;              // "2006-01", "2015-08" hoặc "T+12"
  final int monthIndex;            // Thứ tự tháng (0, 1, 2...)
  final int year;
  final int month;
  final double chiBought;          // Số chỉ vàng mua được trong tháng này
  final double cumulativeChi;      // Số chỉ vàng tích lũy lũy kế đến tháng này
  final double pricePerChi;        // Giá vàng tại thời điểm mua (VND/chỉ)
  final double cumulativeValue;    // Giá trị tài sản vàng lũy kế (VND)
  final double cumulativeInvested; // Tổng số vốn đã trích lũy kế (VND)

  const MonthlyPoint({
    required this.label,
    required this.monthIndex,
    required this.year,
    required this.month,
    required this.chiBought,
    required this.cumulativeChi,
    required this.pricePerChi,
    required this.cumulativeValue,
    required this.cumulativeInvested,
  });

  /// Lợi nhuận ròng lũy kế (VND)
  double get profit => cumulativeValue - cumulativeInvested;

  /// Tỷ suất sinh lời lũy kế (%)
  double get gainPercent {
    return cumulativeInvested > 0 ? (profit / cumulativeInvested) * 100.0 : 0.0;
  }
}

/// Kết quả mô phỏng của một mức tích lũy (% thu nhập)
@immutable
class SimulationResult {
  final int levelPct;              // 10, 15, 20, 25, 30%
  final List<MonthlyPoint> points;

  const SimulationResult({
    required this.levelPct,
    required this.points,
  });

  MonthlyPoint get finalPoint => points.isNotEmpty
      ? points.last
      : const MonthlyPoint(
          label: '',
          monthIndex: 0,
          year: 0,
          month: 0,
          chiBought: 0,
          cumulativeChi: 0,
          pricePerChi: 0,
          cumulativeValue: 0,
          cumulativeInvested: 0,
        );

  double get totalChi => finalPoint.cumulativeChi;
  double get totalValue => finalPoint.cumulativeValue;
  double get totalInvested => finalPoint.cumulativeInvested;
  double get gainPct => finalPoint.gainPercent;
  double get totalProfit => finalPoint.profit;
}

/// Cấu hình đầu vào cho cỗ máy tích sản vàng
@immutable
class AccumulationConfig {
  final double monthlyIncome;
  final List<int> levelsPct;
  final int historyStartYear;
  final int futureYears;
  final double futureCagrPct;
  final double currentPricePerChi;

  const AccumulationConfig({
    required this.monthlyIncome,
    required this.levelsPct,
    required this.historyStartYear,
    required this.futureYears,
    required this.futureCagrPct,
    required this.currentPricePerChi,
  });

  AccumulationConfig copyWith({
    double? monthlyIncome,
    List<int>? levelsPct,
    int? historyStartYear,
    int? futureYears,
    double? futureCagrPct,
    double? currentPricePerChi,
  }) {
    return AccumulationConfig(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      levelsPct: levelsPct ?? this.levelsPct,
      historyStartYear: historyStartYear ?? this.historyStartYear,
      futureYears: futureYears ?? this.futureYears,
      futureCagrPct: futureCagrPct ?? this.futureCagrPct,
      currentPricePerChi: currentPricePerChi ?? this.currentPricePerChi,
    );
  }

  factory AccumulationConfig.defaultConfig() {
    return const AccumulationConfig(
      monthlyIncome: 15000000.0,
      levelsPct: [10, 15, 20, 25, 30],
      historyStartYear: 2006,
      futureYears: 10,
      futureCagrPct: 12.0,
      currentPricePerChi: 14880000.0,
    );
  }
}
