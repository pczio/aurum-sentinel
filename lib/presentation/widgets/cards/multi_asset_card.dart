import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/multi_asset_models.dart';

/// Thẻ so sánh hiệu quả đầu tư đa kênh (Vàng vs Tiết kiệm vs Quỹ mở trái phiếu)
class MultiAssetComparisonCard extends StatelessWidget {
  final MultiAssetComparisonResult comparison;

  const MultiAssetComparisonCard({super.key, required this.comparison});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AurumColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AurumColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.compare_arrows, color: AurumColors.gold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'So Sánh Đa Kênh Đầu Tư Tích Lũy',
                    style: TextStyle(
                      color: AurumColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                'Sau ${comparison.years} năm',
                style: const TextStyle(color: AurumColors.goldBright, fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Trích đều đặn ${CurrencyFormatter.fmtVnd(comparison.monthlyDeposit)}/tháng · Vốn đã bỏ: ${CurrencyFormatter.fmtVnd(comparison.totalInvested)}',
            style: const TextStyle(color: AurumColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 14),

          // 3 Kênh tài sản
          _buildAssetRow(
            title: 'Tích Sản Vàng Nhẫn 9999',
            rateLabel: 'Kỳ vọng ${comparison.goldCagr.toStringAsFixed(1)}%/năm',
            finalValue: comparison.goldFinalValue,
            profit: comparison.goldProfit,
            roi: comparison.goldGainPercent,
            color: AurumColors.gold,
            icon: Icons.adjust,
          ),
          const SizedBox(height: 10),
          _buildAssetRow(
            title: 'Quỹ Mở Trái Phiếu (Bond Fund)',
            rateLabel: 'Lợi suất ${comparison.bondYield.toStringAsFixed(1)}%/năm',
            finalValue: comparison.bondFundFinalValue,
            profit: comparison.bondProfit,
            roi: comparison.bondGainPercent,
            color: AurumColors.sapphire,
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 10),
          _buildAssetRow(
            title: 'Gửi Tiết Kiệm Ngân Hàng',
            rateLabel: 'Lãi suất ${comparison.bankInterestRate.toStringAsFixed(1)}%/năm',
            finalValue: comparison.bankSavingsFinalValue,
            profit: comparison.bankProfit,
            roi: comparison.bankGainPercent,
            color: AurumColors.emerald,
            icon: Icons.account_balance,
          ),
        ],
      ),
    );
  }

  Widget _buildAssetRow({
    required String title,
    required String rateLabel,
    required double finalValue,
    required double profit,
    required double roi,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AurumColors.bgPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AurumColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AurumColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  rateLabel,
                  style: const TextStyle(color: AurumColors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.fmtVnd(finalValue),
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800),
              ),
              Text(
                'Lãi ${CurrencyFormatter.fmtVnd(profit)} (${CurrencyFormatter.fmtPercent(roi)})',
                style: const TextStyle(color: AurumColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
