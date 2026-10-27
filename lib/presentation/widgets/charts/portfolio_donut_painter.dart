import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';

class DonutSegment {
  final String label;
  final double value;
  final Color color;

  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// Biểu đồ hình tròn Donut hiển thị tỷ trọng phân bổ danh mục tài sản
class PortfolioDonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double size;
  final String centerTitle;
  final String centerSubtitle;

  const PortfolioDonutChart({
    super.key,
    required this.segments,
    this.size = 170,
    required this.centerTitle,
    required this.centerSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutChartPainter(segments: segments),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerTitle,
                    style: const TextStyle(
                      color: AurumColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    centerSubtitle,
                    style: const TextStyle(color: AurumColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Chú thích danh mục
        Wrap(
          spacing: 12,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: segments.map((s) {
            final double total = segments.fold(0.0, (acc, e) => acc + e.value);
            final double pct = total > 0 ? (s.value / total) * 100.0 : 0.0;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  '${s.label} (${pct.toStringAsFixed(0)}%)',
                  style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;

  _DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final double total = segments.fold(0.0, (acc, s) => acc + s.value);

    if (total <= 0) return;

    double startAngle = -math.pi / 2;
    const double strokeWidth = 18.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    for (final seg in segments) {
      final double sweepAngle = (seg.value / total) * 2 * math.pi;
      paint.color = seg.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.04, // Khe hở nhỏ tinh tế giữa các phân khúc
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
