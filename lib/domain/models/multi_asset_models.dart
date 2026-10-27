import 'package:flutter/foundation.dart';

/// Điểm so sánh tài sản qua từng năm
@immutable
class MultiAssetComparisonPoint {
  final int year;
  final double investedCapital;
  final double goldValue;
  final double bankSavingsValue;
  final double bondFundValue;

  const MultiAssetComparisonPoint({
    required this.year,
    required this.investedCapital,
    required this.goldValue,
    required this.bankSavingsValue,
    required this.bondFundValue,
  });
}

/// Kết quả so sánh hiệu quả giữa Vàng vs Gửi tiết kiệm vs Quỹ mở trái phiếu
@immutable
class MultiAssetComparisonResult {
  final int years;
  final double monthlyDeposit;
  final double totalInvested;
  final double goldFinalValue;
  final double bankSavingsFinalValue;
  final double bondFundFinalValue;
  final double goldCagr;
  final double bankInterestRate;
  final double bondYield;
  final List<MultiAssetComparisonPoint> yearlyPoints;

  const MultiAssetComparisonResult({
    required this.years,
    required this.monthlyDeposit,
    required this.totalInvested,
    required this.goldFinalValue,
    required this.bankSavingsFinalValue,
    required this.bondFundFinalValue,
    required this.goldCagr,
    required this.bankInterestRate,
    required this.bondYield,
    required this.yearlyPoints,
  });

  double get goldProfit => goldFinalValue - totalInvested;
  double get bankProfit => bankSavingsFinalValue - totalInvested;
  double get bondProfit => bondFundFinalValue - totalInvested;

  double get goldGainPercent => totalInvested > 0 ? (goldProfit / totalInvested) * 100.0 : 0.0;
  double get bankGainPercent => totalInvested > 0 ? (bankProfit / totalInvested) * 100.0 : 0.0;
  double get bondGainPercent => totalInvested > 0 ? (bondProfit / totalInvested) * 100.0 : 0.0;
}

/// Mô hình phân bổ tài sản "Rổ 80-20"
@immutable
class Portfolio8020Allocation {
  final double monthlyIncome;         // Lương tháng (15 triệu)
  final double savingsPercent;        // Tỷ lệ trích tiết kiệm (20% = 3 triệu)
  final double goldInSavingsPercent;  // Tỷ lệ vàng trong phần tiết kiệm (20% hoặc 50%)
  final double emergencyMonths;       // Quỹ dự phòng số tháng chi tiêu (ví dụ 6 tháng)

  const Portfolio8020Allocation({
    required this.monthlyIncome,
    required this.savingsPercent,
    required this.goldInSavingsPercent,
    required this.emergencyMonths,
  });

  /// Số tiền dành cho sinh hoạt hàng tháng
  double get livingExpenseVnd => monthlyIncome * (1.0 - (savingsPercent / 100.0));

  /// Tổng số tiền tiết kiệm hàng tháng
  double get totalMonthlySavingsVnd => monthlyIncome * (savingsPercent / 100.0);

  /// Số tiền mua vàng nhẫn tích lũy mỗi tháng
  double get monthlyGoldVnd => totalMonthlySavingsVnd * (goldInSavingsPercent / 100.0);

  /// Số tiền gửi ngân hàng / quỹ trái phiếu mỗi tháng
  double get monthlyLiquidSavingsVnd => totalMonthlySavingsVnd * (1.0 - (goldInSavingsPercent / 100.0));

  /// Quy mô quỹ khẩn cấp mục tiêu (VND)
  double get targetEmergencyFundVnd => livingExpenseVnd * emergencyMonths;
}
