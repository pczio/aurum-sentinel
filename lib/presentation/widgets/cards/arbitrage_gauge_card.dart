import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/arbitrage_result.dart';

/// Thẻ trực quan hóa chỉ số SJC Arbitrage Spread Index (ASI)
class ArbitrageGaugeCard extends StatelessWidget {
  final ArbitrageResult arbitrage;
  final VoidCallback? onCalculateTap;

  const ArbitrageGaugeCard({
    super.key,
    required this.arbitrage,
    this.onCalculateTap,
  });

  @override
  Widget build(BuildContext context) {
    // Đo lường thanh tiến độ từ 0 đến 20 triệu chênh lệch
    const double maxRange = 20000000.0;
    final double fraction = (arbitrage.asi / maxRange).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AurumColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: arbitrage.statusColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.balance, color: arbitrage.statusColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'SJC Arbitrage Spread Index (ASI)',
                    style: TextStyle(
                      color: AurumColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (onCalculateTap != null)
                InkWell(
                  onTap: onCalculateTap,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.calculate_outlined, color: AurumColors.gold, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Giá trị ASI to bản
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.fmtVnd(arbitrage.asi),
                style: TextStyle(
                  color: arbitrage.statusColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '(Premium ${arbitrage.premiumPercent.toStringAsFixed(1)}%)',
                  style: TextStyle(color: arbitrage.statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Thanh thước đo màu sắc 3 phân vùng
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Row(
                    children: [
                      // 0 - 5 triệu: An toàn (Xanh)
                      Expanded(flex: 25, child: Container(color: AurumColors.emerald.withOpacity(0.35))),
                      // 5 - 12 triệu: Trung tính (Vàng)
                      Expanded(flex: 35, child: Container(color: AurumColors.amber.withOpacity(0.35))),
                      // 12 - 20 triệu: Nguy cơ (Đỏ)
                      Expanded(flex: 40, child: Container(color: AurumColors.ruby.withOpacity(0.35))),
                    ],
                  ),
                  // Con trỏ định vị giá trị hiện hành
                  FractionallySizedBox(
                    widthFactor: fraction,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 4,
                        height: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Chú thích mốc phân vùng
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0đ (Chuẩn)', style: TextStyle(color: AurumColors.textMuted, fontSize: 9.5)),
              Text('5 tr (Vùng an toàn)', style: TextStyle(color: AurumColors.emerald, fontSize: 9.5)),
              Text('12 tr (Ngưỡng cảnh báo)', style: TextStyle(color: AurumColors.ruby, fontSize: 9.5)),
            ],
          ),
          const SizedBox(height: 12),

          // Lời khuyên hành động
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AurumColors.bgPanel,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AurumColors.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(
                  arbitrage.zone == ArbitrageZone.safe
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  color: arbitrage.statusColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    arbitrage.suggestedAction,
                    style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11.5, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
