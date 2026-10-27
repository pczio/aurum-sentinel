import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/gemini_advisory_signal.dart';

/// Thẻ chiến lược phân tích cố vấn tài chính Gemini AI
class GeminiSignalCard extends StatelessWidget {
  final GeminiAdvisorySignal signal;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const GeminiSignalCard({
    super.key,
    required this.signal,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AurumColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: signal.signalColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: signal.signalColor.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề & Nút phân tích lại
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AurumColors.goldDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AurumColors.goldBright, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Gemini AI Financial Intelligence',
                    style: TextStyle(
                      color: AurumColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (onRefresh != null)
                IconButton(
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AurumColors.gold),
                        )
                      : const Icon(Icons.refresh, color: AurumColors.gold, size: 20),
                  onPressed: isLoading ? null : onRefresh,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Tín hiệu hành động to bản & Điểm tin cậy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: signal.signalColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: signal.signalColor, width: 1.2),
                ),
                child: Text(
                  signal.signalLabel,
                  style: TextStyle(
                    color: signal.signalColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Row(
                children: [
                  const Text('Độ tin cậy: ', style: TextStyle(color: AurumColors.textMuted, fontSize: 11)),
                  Text(
                    '${signal.confidenceScore}%',
                    style: TextStyle(
                      color: signal.confidenceScore >= 85 ? AurumColors.emerald : AurumColors.gold,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tiêu đề khuyến nghị tóm tắt
          Text(
            signal.headline,
            style: const TextStyle(
              color: AurumColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // 3 Chỉ số thực thi: Mục tiêu TP, Cắt lỗ SL, Tỷ trọng % NAV
          Row(
            children: [
              _buildTargetBox(
                label: 'Mục Tiêu (TP)',
                value: CurrencyFormatter.fmtUsd(signal.targetPriceUsd),
                color: AurumColors.emerald,
              ),
              const SizedBox(width: 8),
              _buildTargetBox(
                label: 'Cắt Lỗ (SL)',
                value: CurrencyFormatter.fmtUsd(signal.stopLossUsd),
                color: AurumColors.ruby,
              ),
              const SizedBox(width: 8),
              _buildTargetBox(
                label: 'Tỷ Trọng NAV',
                value: '${signal.navAllocationPct.toStringAsFixed(0)}% vốn',
                color: AurumColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Lập luận vĩ mô chi tiết
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AurumColors.bgPanel,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AurumColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AurumColors.gold, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Lập luận vĩ mô & Chu kỳ kinh tế',
                      style: TextStyle(color: AurumColors.goldBright, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  signal.macroReasoning,
                  style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11.5, height: 1.4),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AurumColors.border),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.storefront_outlined, color: AurumColors.sapphire, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Thị trường vàng Việt Nam (SJC & Nhẫn 9999)',
                      style: TextStyle(color: AurumColors.sapphire, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  signal.domesticAdvice,
                  style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: AurumColors.bgPanel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AurumColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AurumColors.textMuted, fontSize: 9.5)),
            const SizedBox(height: 2),
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
