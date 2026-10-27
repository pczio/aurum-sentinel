import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptic_feedback_helper.dart';
import '../../../domain/models/arbitrage_result.dart';
import '../../../domain/models/gemini_advisory_signal.dart';
import '../../../domain/models/gold_price_snapshot.dart';

/// Khung nổi Mini-HUD (Floating Gold Mini-HUD) xem nhanh giá và tín hiệu tức thời
class FloatingMiniHudWidget extends StatefulWidget {
  final GoldPriceSnapshot snapshot;
  final ArbitrageResult arbitrage;
  final GeminiAdvisorySignal? signal;

  const FloatingMiniHudWidget({
    super.key,
    required this.snapshot,
    required this.arbitrage,
    this.signal,
  });

  @override
  State<FloatingMiniHudWidget> createState() => _FloatingMiniHudWidgetState();
}

class _FloatingMiniHudWidgetState extends State<FloatingMiniHudWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AurumColors.bgCardElevated.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AurumColors.borderGold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dòng thanh gọn luôn hiển thị
          InkWell(
            onTap: () {
              HapticHelper.selectionClick();
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Row(
              children: [
                // Đèn tín hiệu nhấp nháy
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.signal?.signalColor ?? AurumColors.emerald,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.signal?.signalColor ?? AurumColors.emerald,
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'XAU: ${CurrencyFormatter.fmtUsd(widget.snapshot.xauUsd)}',
                  style: const TextStyle(
                    color: AurumColors.goldBright,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SJC: ${CurrencyFormatter.fmtVnd(widget.snapshot.sjcSellPerLuong)}',
                  style: const TextStyle(
                    color: AurumColors.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (widget.signal?.signalColor ?? AurumColors.emerald).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.signal?.signalLabel ?? 'MUA TÍCH SẢN',
                    style: TextStyle(
                      color: widget.signal?.signalColor ?? AurumColors.emerald,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AurumColors.textMuted,
                  size: 16,
                ),
              ],
            ),
          ),

          // Vùng mở rộng chi tiết khi bấm
          if (_isExpanded) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AurumColors.borderSubtle),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSubItem('Nhẫn 9999', CurrencyFormatter.fmtVnd(widget.snapshot.ringSellPerChi), AurumColors.gold),
                _buildSubItem('Chênh lệch ASI', CurrencyFormatter.fmtVnd(widget.arbitrage.asi), widget.arbitrage.statusColor),
                _buildSubItem('Tỷ giá USD/VND', CurrencyFormatter.fmtVnd(widget.snapshot.usdVnd), AurumColors.textSecondary),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AurumColors.textMuted, fontSize: 9.5)),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
