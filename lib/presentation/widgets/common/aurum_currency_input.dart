import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/haptic_feedback_helper.dart';

/// Ô nhập số tiền tài chính VNĐ với phím tắt gợi ý nhanh
class AurumCurrencyInput extends StatefulWidget {
  final String label;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final String suffix;
  final List<double>? quickPresets;

  const AurumCurrencyInput({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.suffix = 'đ',
    this.quickPresets,
  });

  @override
  State<AurumCurrencyInput> createState() => _AurumCurrencyInputState();
}

class _AurumCurrencyInputState extends State<AurumCurrencyInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: CurrencyFormatter.fmtVnd(widget.initialValue, short: false).replaceAll(' đ', ''));
  }

  @override
  void didUpdateWidget(covariant AurumCurrencyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      final text = CurrencyFormatter.fmtVnd(widget.initialValue, short: false).replaceAll(' đ', '');
      if (_controller.text != text) {
        _controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPresetTapped(double value) {
    HapticHelper.selectionClick();
    setState(() {
      _controller.text = CurrencyFormatter.fmtVnd(value, short: false).replaceAll(' đ', '');
    });
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AurumColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AurumColors.bgPanel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AurumColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  style: const TextStyle(
                    color: AurumColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    final double parsed = CurrencyFormatter.parseVnd(val, widget.initialValue);
                    widget.onChanged(parsed);
                  },
                ),
              ),
              Text(
                widget.suffix,
                style: const TextStyle(
                  color: AurumColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (widget.quickPresets != null && widget.quickPresets!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: widget.quickPresets!.map((preset) {
              final bool isSelected = (preset == widget.initialValue);
              return InkWell(
                onTap: () => _onPresetTapped(preset),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AurumColors.gold.withOpacity(0.18) : AurumColors.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AurumColors.gold : AurumColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    CurrencyFormatter.fmtVnd(preset),
                    style: TextStyle(
                      color: isSelected ? AurumColors.goldBright : AurumColors.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
