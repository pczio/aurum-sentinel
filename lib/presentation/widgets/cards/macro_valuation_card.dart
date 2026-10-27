import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/macro_indicators.dart';

/// Thẻ mô hình định giá vĩ mô XAU Fair Value Model
class MacroValuationCard extends StatelessWidget {
  final MacroIndicators macro;

  const MacroValuationCard({super.key, required this.macro});

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
                  Icon(Icons.analytics_outlined, color: AurumColors.sapphire, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Định Giá Vĩ Mô XAU Fair Value (P*)',
                    style: TextStyle(
                      color: AurumColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: macro.stateColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: macro.stateColor.withOpacity(0.4)),
                ),
                child: Text(
                  macro.stateLabel,
                  style: TextStyle(color: macro.stateColor, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // So sánh Giá thị trường vs Giá trị hợp lý vĩ mô
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giá Hợp Lý Vĩ Mô (P*)', style: TextStyle(color: AurumColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text(
                      CurrencyFormatter.fmtUsd(macro.fairValueXau),
                      style: const TextStyle(
                        color: AurumColors.goldBright,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: AurumColors.border),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giá Thị Trường Thực Tế', style: TextStyle(color: AurumColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text(
                      CurrencyFormatter.fmtUsd(macro.marketPriceXau),
                      style: const TextStyle(
                        color: AurumColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Biến số vĩ mô then chốt
          Row(
            children: [
              _buildMetricPill(
                label: '10Y TIPS (DFII10)',
                value: '${macro.tips10Y.toStringAsFixed(2)}%',
                icon: Icons.trending_down,
                color: AurumColors.sapphire,
                tooltip: 'Tương quan nghịch đảo chủ đạo beta = 0.65',
              ),
              const SizedBox(width: 8),
              _buildMetricPill(
                label: 'USD Index (DXY)',
                value: macro.dxy.toStringAsFixed(1),
                icon: Icons.attach_money,
                color: AurumColors.cyan,
                tooltip: 'Sức mạnh đồng đô la Mỹ',
              ),
              const SizedBox(width: 8),
              _buildMetricPill(
                label: 'Mua NHTW',
                value: '${macro.cbNetBuyTons.toStringAsFixed(0)}T/th',
                icon: Icons.account_balance,
                color: AurumColors.emerald,
                tooltip: 'Lực đỡ tích lũy từ các Ngân hàng Trung ương',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AurumColors.bgPanel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AurumColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: AurumColors.textMuted, fontSize: 9.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
