import 'dart:math' as math;
import '../models/multi_asset_models.dart';

/// Cỗ máy định lượng so sánh đa kênh tài sản & Rổ phân bổ 80-20
class MultiAssetEngine {
  MultiAssetEngine._();

  /// So sánh lợi suất đầu tư tích lũy hàng tháng giữa Vàng vs Gửi tiết kiệm vs Quỹ mở trái phiếu
  static MultiAssetComparisonResult compareVehicles({
    required double monthlyDeposit,
    required int years,
    double goldAnnualCagr = 10.5,       // Tăng trưởng vàng bình quân 10.5%/năm
    double bankInterestRate = 5.5,      // Lãi suất gửi tiết kiệm ngân hàng 5.5%/năm
    double bondYield = 7.8,             // Lợi suất quỹ trái phiếu 7.8%/năm
  }) {
    final int totalMonths = years * 12;
    final double goldMonthlyGrowth = math.pow(1.0 + goldAnnualCagr / 100.0, 1.0 / 12.0) - 1.0;
    final double bankMonthlyRate = bankInterestRate / 100.0 / 12.0;
    final double bondMonthlyRate = bondYield / 100.0 / 12.0;

    double cumGoldInvested = 0.0;
    double cumGoldOunces = 0.0;
    double goldPrice = 14880000.0; // Giá khởi điểm

    double bankTotal = 0.0;
    double bondTotal = 0.0;

    final List<MultiAssetComparisonPoint> points = [];

    for (int m = 1; m <= totalMonths; m++) {
      // 1. Tích lũy Vàng: Mua theo giá từng tháng
      cumGoldInvested += monthlyDeposit;
      final double chiBought = monthlyDeposit / goldPrice;
      cumGoldOunces += chiBought;
      goldPrice *= (1.0 + goldMonthlyGrowth);

      // 2. Gửi tiết kiệm: Lãi nhập gốc hàng tháng
      bankTotal = (bankTotal + monthlyDeposit) * (1.0 + bankMonthlyRate);

      // 3. Quỹ mở trái phiếu: Tái đầu tư lợi tức hàng tháng
      bondTotal = (bondTotal + monthlyDeposit) * (1.0 + bondMonthlyRate);

      // Lưu lại điểm snapshot ở cuối mỗi năm
      if (m % 12 == 0) {
        final int currentYear = m ~/ 12;
        final double currentGoldVal = cumGoldOunces * goldPrice;

        points.add(
          MultiAssetComparisonPoint(
            year: currentYear,
            investedCapital: cumGoldInvested,
            goldValue: currentGoldVal,
            bankSavingsValue: bankTotal,
            bondFundValue: bondTotal,
          ),
        );
      }
    }

    final double finalGoldVal = cumGoldOunces * goldPrice;

    return MultiAssetComparisonResult(
      years: years,
      monthlyDeposit: monthlyDeposit,
      totalInvested: cumGoldInvested,
      goldFinalValue: finalGoldVal,
      bankSavingsFinalValue: bankTotal,
      bondFundFinalValue: bondTotal,
      goldCagr: goldAnnualCagr,
      bankInterestRate: bankInterestRate,
      bondYield: bondYield,
      yearlyPoints: points,
    );
  }

  /// Tính toán chi tiết kế hoạch tài chính cá nhân theo Rổ phân bổ 80-20
  static Portfolio8020Allocation calculate8020({
    required double monthlyIncome,
    double savingsPercent = 20.0,         // 20% thu nhập để tiết kiệm (3 triệu từ 15tr)
    double goldInSavingsPercent = 20.0,   // Trong phần tiết kiệm, trích 20% mua vàng (600k) hoặc 50%
    double emergencyMonths = 6.0,         // Dự phòng 6 tháng chi phí sinh hoạt
  }) {
    return Portfolio8020Allocation(
      monthlyIncome: monthlyIncome,
      savingsPercent: savingsPercent,
      goldInSavingsPercent: goldInSavingsPercent,
      emergencyMonths: emergencyMonths,
    );
  }
}
