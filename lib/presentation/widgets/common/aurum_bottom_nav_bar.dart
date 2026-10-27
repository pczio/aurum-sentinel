import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/haptic_feedback_helper.dart';

/// Thanh điều hướng dưới đáy (Bottom Navigation Bar) chuẩn tài chính cao cấp
class AurumBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AurumBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AurumColors.bgPanel,
        border: Border(top: BorderSide(color: AurumColors.borderSubtle, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.query_stats,
                label: 'Thị Trường',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.stacked_line_chart,
                label: 'Tích Sản',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.crisis_alert,
                label: 'Kịch Bản',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.auto_awesome,
                label: 'Gemini AI',
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.lock_outline,
                label: 'Két Vàng',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;
    final Color color = isSelected ? AurumColors.gold : AurumColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            HapticHelper.lightImpact();
            onTap(index);
          }
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AurumColors.gold.withOpacity(0.14) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
