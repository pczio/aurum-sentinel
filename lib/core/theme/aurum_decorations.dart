import 'package:flutter/material.dart';
import '../constants/aurum_colors.dart';

/// Các mẫu trang trí hộp (BoxDecoration) chuẩn thiết kế Aurum
class AurumDecorations {
  AurumDecorations._();

  /// Thẻ tài chính chuẩn
  static BoxDecoration card({
    Color bg = AurumColors.bgCard,
    Color borderColor = AurumColors.border,
    double radius = 16,
    bool glow = false,
  }) {
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: glow
          ? [
              BoxShadow(
                color: borderColor.withOpacity(0.12),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              )
            ]
          : null,
    );
  }

  /// Thẻ viền ánh kim vàng (Gold Premium Card)
  static BoxDecoration goldCard({double radius = 16}) {
    return BoxDecoration(
      color: AurumColors.bgCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AurumColors.borderGold, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: AurumColors.gold.withOpacity(0.08),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Khung hiệu ứng thủy tinh mờ (Glassmorphism)
  static BoxDecoration glass({double radius = 16}) {
    return BoxDecoration(
      color: AurumColors.bgGlass,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AurumColors.border.withOpacity(0.6), width: 1),
    );
  }

  /// Nút dạng viên thuốc (Accent Pill / Badge)
  static BoxDecoration pill({
    required Color color,
    double radius = 999,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withOpacity(0.4), width: 1),
    );
  }

  /// Dải viền chuyển sắc
  static BoxDecoration gradientBorderCard({
    required Gradient gradient,
    double radius = 16,
    Color bg = AurumColors.bgCard,
  }) {
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AurumColors.border, width: 1),
    );
  }
}
