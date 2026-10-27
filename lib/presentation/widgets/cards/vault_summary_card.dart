import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/gold_unit_converter.dart';
import '../../../domain/models/gold_vault_item.dart';

/// Thẻ tổng quan tài sản trong Két Vàng cá nhân
class VaultSummaryCard extends StatelessWidget {
  final VaultSummary summary;
  final VoidCallback? onAddTap;

  const VaultSummaryCard({super.key, required this.summary, this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final bool isProfitable = summary.netProfit >= 0;
    final Color pnlColor = isProfitable
        ? AurumColors.emerald
        : AurumColors.ruby;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AurumColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AurumColors.borderGold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AurumColors.gold.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề & Nút thêm giao dịch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AurumColors.goldDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: AurumColors.goldBright,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Két Vàng Cá Nhân',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AurumColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (onAddTap != null)
                ElevatedButton.icon(
                  onPressed: onAddTap,
                  icon: const Icon(Icons.add, size: 15),
                  label: const Text('Thêm Vàng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AurumColors.gold,
                    foregroundColor: const Color(0xFF141002),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Tổng giá trị tài sản thị trường
          const Text(
            'Tổng Định Giá Thị Trường Hiện Tại',
            style: TextStyle(color: AurumColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            CurrencyFormatter.fmtVnd(summary.currentMarketValue),
            style: const TextStyle(
              color: AurumColors.goldBright,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // 3 Cột: Khối lượng vàng, Vốn gốc, Lợi nhuận PnL
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Khối Lượng Vàng',
                  value: GoldUnitConverter.fmtChi(
                    summary.totalChi,
                    decimals: 2,
                  ),
                  subtitle: GoldUnitConverter.fmtTraditional(summary.totalChi),
                  color: AurumColors.textPrimary,
                ),
              ),
              Container(width: 1, height: 32, color: AurumColors.border),
              Expanded(
                child: _buildMetricItem(
                  title: 'Vốn Gốc Đã Chi',
                  value: CurrencyFormatter.fmtVnd(summary.totalInvested),
                  subtitle: '${summary.totalItems} món vàng',
                  color: AurumColors.textSecondary,
                ),
              ),
              Container(width: 1, height: 32, color: AurumColors.border),
              Expanded(
                child: _buildMetricItem(
                  title: 'Lợi Nhuận (P&L)',
                  value: CurrencyFormatter.fmtVnd(summary.netProfit),
                  subtitle: CurrencyFormatter.fmtPercent(summary.roiPercent),
                  color: pnlColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AurumColors.textMuted, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
