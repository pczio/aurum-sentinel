import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/haptic_feedback_helper.dart';

/// Thanh trượt chọn giá trị số chuyên dụng kèm hiển thị trực quan
class AurumSliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const AurumSliderField({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: AurumColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AurumColors.goldDark,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AurumColors.borderGold),
              ),
              child: Text(
                displayValue,
                style: const TextStyle(color: AurumColors.goldBright, fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AurumColors.gold,
            inactiveTrackColor: AurumColors.border,
            thumbColor: AurumColors.goldBright,
            overlayColor: AurumColors.gold.withOpacity(0.15),
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: (val) {
              HapticHelper.selectionClick();
              onChanged(val);
            },
          ),
        ),
      ],
    );
  }
}
