import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';

/// Thẻ số liệu tài chính KPI chuẩn mực AurumSentinel
class AurumStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color accentColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const AurumStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.accentColor = AurumColors.gold,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AurumColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AurumColors.border),
        ),
        child: Row(
          children: [
            // Thanh gạch màu nhấn trái
            Container(
              width: 3.5,
              height: 38,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AurumColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AurumColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (icon != null) ...[
              Icon(icon, color: accentColor.withOpacity(0.8), size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
