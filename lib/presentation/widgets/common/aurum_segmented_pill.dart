import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/haptic_feedback_helper.dart';

class SegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SegmentItem({required this.value, required this.label, this.icon});
}

/// Nút chọn phân đoạn hình viên thuốc (Segmented Pill Selector)
class AurumSegmentedPill<T> extends StatelessWidget {
  final List<SegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  const AurumSegmentedPill({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: AurumColors.bgPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AurumColors.border),
      ),
      child: Row(
        children: items.map((item) {
          final bool isSelected = (item.value == selectedValue);

          return Expanded(
            child: InkWell(
              onTap: () {
                if (!isSelected) {
                  HapticHelper.lightImpact();
                  onSelected(item.value);
                }
              },
              borderRadius: BorderRadius.circular(9),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AurumColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AurumColors.gold.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 14,
                        color: isSelected
                            ? const Color(0xFF141002)
                            : AurumColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Flexible(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF141002)
                              : AurumColors.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
