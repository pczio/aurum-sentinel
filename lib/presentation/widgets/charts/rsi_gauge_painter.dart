import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';

/// Đồng hồ đo chỉ số RSI 14 chu kỳ (RSI Arc Gauge)
class RsiGaugeWidget extends StatelessWidget {
  final double rsiValue;
  final double size;

  const RsiGaugeWidget({
    super.key,
    required this.rsiValue,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    Color gaugeColor = AurumColors.gold;
    String status = 'Trung tính';

    if (rsiValue < 30) {
      gaugeColor = AurumColors.emerald;
      status = 'Quá Bán (Oversold)';
    } else if (rsiValue > 70) {
      gaugeColor = AurumColors.ruby;
      status = 'Quá Mua (Overbought)';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size * 0.72,
          child: CustomPaint(
            painter: _RsiArcPainter(rsiValue: rsiValue, activeColor: gaugeColor),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: size * 0.15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rsiValue.toStringAsFixed(1),
                      style: TextStyle(
                        color: gaugeColor,
                        fontSize: size * 0.19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text('RSI 14', style: TextStyle(color: AurumColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
        ),
        Text(
          status,
          style: TextStyle(color: gaugeColor, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _RsiArcPainter extends CustomPainter {
  final double rsiValue;
  final Color activeColor;

  _RsiArcPainter({required this.rsiValue, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.78);
    final radius = size.width * 0.42;

    const startAngle = math.pi * 0.82;
    const sweepAngle = math.pi * 1.36;

    // 1. Vành nền xám
    final bgPaint = Paint()
      ..color = AurumColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // 2. Vành tiến độ active
    final double fraction = (rsiValue / 100.0).clamp(0.0, 1.0);
    final activeSweep = sweepAngle * fraction;

    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RsiArcPainter oldDelegate) {
    return oldDelegate.rsiValue != rsiValue || oldDelegate.activeColor != activeColor;
  }
}
