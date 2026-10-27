import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';

/// Logo chính thức của AurumSentinel:
/// Biểu tượng Nhẫn Vàng Tròn (Nhẫn 999.9), bên trong là các thỏi vàng xếp tầng hoàng kim
class AurumLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const AurumLogo({
    super.key,
    this.size = 36,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AurumColors.gold.withValues(alpha: 0.25),
                  blurRadius: size * 0.25,
                  spreadRadius: size * 0.02,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _GoldRingBarsLogoPainter(),
      ),
    );
  }
}

class _GoldRingBarsLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);
    final double radius = w / 2;

    // 1. Nền tròn Obsidian siêu tối bên trong nhẫn
    final Paint bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AurumColors.bgCard,
          AurumColors.bgRoot,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 1, bgPaint);

    // 2. Vành Nhẫn Chỉ Vàng Tròn 999.9 (Gold Ring Band)
    final double ringStrokeWidth = w * 0.085;
    final double ringRadius = radius - ringStrokeWidth / 2 - 1.0;

    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStrokeWidth
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFFF6D1), // Ánh vàng lấp lánh (Specular highlight)
          Color(0xFFFFD700), // Vàng rực 999.9
          Color(0xFFC59B27), // Vàng kim đậm
          Color(0xFF8B6508), // Vàng bóng tối
          Color(0xFFFFD700), // Vàng rực
          Color(0xFFFFF6D1), // Ánh vàng
        ],
        stops: [0.0, 0.25, 0.5, 0.72, 0.88, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: ringRadius));

    canvas.drawCircle(center, ringRadius, ringPaint);

    // Vòng viền vàng siêu mảnh bên ngoài và bên trong nhẫn tạo chiều sâu 3D
    final Paint rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = const Color(0xFFFFF3B0).withValues(alpha: 0.7);
    canvas.drawCircle(center, radius - 1.0, rimPaint);

    final Paint innerRimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = const Color(0xFF996515).withValues(alpha: 0.8);
    canvas.drawCircle(center, radius - ringStrokeWidth - 1.0, innerRimPaint);

    // 3. Thỏi Vàng Xếp Chồng (Stacked Gold Bullion Bars) ở giữa lòng nhẫn
    // Mô hình kim tự tháp tài chính vững chãi: 2 thỏi tầng dưới, 1 thỏi đỉnh
    _drawGoldBars(canvas, w, h);
  }

  void _drawGoldBars(Canvas canvas, double w, double h) {
    // Kích thước các thỏi vàng theo tỷ lệ % kích thước logo
    final double barH = h * 0.14;

    // === Tầng dưới bên trái (Bottom Left Bar) ===
    final double b1X = w * 0.18;
    final double b1Y = h * 0.52;
    final double b1W = w * 0.30;
    _drawSingleBar(canvas, Rect.fromLTWH(b1X, b1Y, b1W, barH));

    // === Tầng dưới bên phải (Bottom Right Bar) ===
    final double b2X = w * 0.52;
    final double b2Y = h * 0.52;
    final double b2W = w * 0.30;
    _drawSingleBar(canvas, Rect.fromLTWH(b2X, b2Y, b2W, barH));

    // === Tầng trên ở giữa (Top Centered Bar) ===
    final double topX = w * 0.31;
    final double topY = h * 0.34;
    final double topW = w * 0.38;
    _drawSingleBar(canvas, Rect.fromLTWH(topX, topY, topW, barH), isTop: true);
  }

  void _drawSingleBar(Canvas canvas, Rect rect, {bool isTop = false}) {
    final double cornerR = rect.height * 0.22;
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerR));

    // Thân thỏi vàng gradient kim loại
    final Paint barPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isTop
            ? const [
                Color(0xFFFFF9E6), // Đỉnh thỏi đón sáng mạnh
                Color(0xFFFFD873),
                Color(0xFFE6B94D),
                Color(0xFF9E731C),
              ]
            : const [
                Color(0xFFFFEFA8),
                Color(0xFFE6B94D),
                Color(0xFFC5952C),
                Color(0xFF7A560E),
              ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, barPaint);

    // Đường vát cạnh phản quang trên mặt thỏi vàng (Beveled top highlight)
    final double topBevelH = rect.height * 0.35;
    final Rect topBevelRect = Rect.fromLTWH(
      rect.left + rect.width * 0.08,
      rect.top + rect.height * 0.08,
      rect.width * 0.84,
      topBevelH,
    );
    final RRect topBevelRRect = RRect.fromRectAndRadius(
      topBevelRect,
      Radius.circular(cornerR * 0.6),
    );

    final Paint bevelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: isTop ? 0.75 : 0.55),
          const Color(0xFFFFD873).withValues(alpha: 0.1),
        ],
      ).createShader(topBevelRect);

    canvas.drawRRect(topBevelRRect, bevelPaint);

    // Khắc viền mảnh sắc nét quanh thỏi
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65
      ..color = const Color(0xFF63460A).withValues(alpha: 0.7);
    canvas.drawRRect(rrect, borderPaint);

    // Ký hiệu khắc chìm mini trên đỉnh thỏi trên (dấu ấn vàng 9999)
    if (isTop && rect.width > 20) {
      final Paint stampPaint = Paint()
        ..color = const Color(0xFF8B6508).withValues(alpha: 0.85)
        ..strokeWidth = 0.6;
      final double stampY = rect.top + rect.height * 0.65;
      canvas.drawLine(
        Offset(rect.left + rect.width * 0.32, stampY),
        Offset(rect.right - rect.width * 0.32, stampY),
        stampPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
