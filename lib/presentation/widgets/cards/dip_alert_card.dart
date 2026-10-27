import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/dip_signal_models.dart';
import '../charts/rsi_gauge_painter.dart';

/// Thẻ radar phát hiện nhịp giảm và săn đáy (Dip-Buying Radar)
class DipAlertCard extends StatelessWidget {
  final DipSignal dipSignal;

  const DipAlertCard({super.key, required this.dipSignal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AurumColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dipSignal.severityColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.radar, color: dipSignal.severityColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Radar Bắt Đáy & Mua Theo Nhịp Giảm',
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
                  color: dipSignal.severityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: dipSignal.severityColor.withOpacity(0.4)),
                ),
                child: Text(
                  dipSignal.severityLabel,
                  style: TextStyle(color: dipSignal.severityColor, fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Đồng hồ đo RSI 14
              RsiGaugeWidget(rsiValue: dipSignal.rsi14, size: 110),
              const SizedBox(width: 14),

              // Chỉ số sụt giảm & Ngân sách gợi ý
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Độ sụt giảm đỉnh 30 ngày:',
                      style: const TextStyle(color: AurumColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${dipSignal.drawdownPercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: dipSignal.drawdownPercent <= -3 ? AurumColors.emerald : AurumColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(Đỉnh: ${CurrencyFormatter.fmtVnd(dipSignal.peakPrice30d)})',
                          style: const TextStyle(color: AurumColors.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gợi ý ngân sách giải ngân nhịp này:',
                      style: const TextStyle(color: AurumColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.fmtVnd(dipSignal.suggestedBuyVnd),
                          style: const TextStyle(
                            color: AurumColors.goldBright,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AurumColors.gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${dipSignal.extraBudgetMultiplier}x DCA',
                            style: const TextStyle(color: AurumColors.gold, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Lập luận căn cứ bắt đáy
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AurumColors.bgPanel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AurumColors.borderSubtle),
            ),
            child: Text(
              dipSignal.rationale,
              style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
