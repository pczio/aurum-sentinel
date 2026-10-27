import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/haptic_feedback_helper.dart';

/// Nút bấm ánh kim vàng sang trọng (Gold Action Button)
class AurumButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;
  final double height;

  const AurumButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return OutlinedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticHelper.lightImpact();
                onPressed?.call();
              },
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, height),
          side: const BorderSide(color: AurumColors.borderGold, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _buildContent(AurumColors.goldBright),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: AurumColors.goldGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AurumColors.gold.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticHelper.mediumImpact();
                onPressed?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: const Color(0xFF141002),
          minimumSize: Size(double.infinity, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _buildContent(const Color(0xFF141002)),
      ),
    );
  }

  Widget _buildContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
