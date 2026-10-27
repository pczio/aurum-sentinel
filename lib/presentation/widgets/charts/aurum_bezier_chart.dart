import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/haptic_feedback_helper.dart';

/// Dữ liệu một chuỗi đường biểu đồ (Series)
class AurumChartSeries {
  final String name;
  final Color color;
  final List<double> values;
  final bool isDashed;
  final double strokeWidth;
  final bool showGradientFill;

  const AurumChartSeries({
    required this.name,
    required this.color,
    required this.values,
    this.isDashed = false,
    this.strokeWidth = 2.4,
    this.showGradientFill = false,
  });
}

/// Biểu đồ đường cong Bezier tương tác cao cấp (Custom Canvas Painter)
/// Hỗ trợ:
/// 1. Rê tay/chuột chọn từng cột năm với dải màu Highlight cột (Golden Column Strip).
/// 2. Bảng HUD hiển thị số liệu trực quan nhảy theo thời gian thực cho từng năm.
/// 3. Tooltip nổi bám theo ngón tay/chuột với điểm sáng tròn (Glow Node).
/// 4. Giữ trạng thái hiển thị (Sticky Selection) khi nhấc tay, tránh bị mất số liệu.
class AurumBezierChart extends StatefulWidget {
  final List<AurumChartSeries> series;
  final List<String> xLabels;
  final String Function(double value)? yFormatter;
  final double height;
  final String? title;
  final String? subtitle;

  const AurumBezierChart({
    super.key,
    required this.series,
    required this.xLabels,
    this.yFormatter,
    this.height = 240,
    this.title,
    this.subtitle,
  });

  @override
  State<AurumBezierChart> createState() => _AurumBezierChartState();
}

class _AurumBezierChartState extends State<AurumBezierChart> {
  int? _hoveredIndex;
  double? _touchX;
  bool _isInteracting = false;

  @override
  Widget build(BuildContext context) {
    if (widget.series.isEmpty || widget.series.first.values.isEmpty) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AurumColors.bgPanel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AurumColors.border),
        ),
        child: const Text(
          'Chưa có dữ liệu biểu đồ',
          style: TextStyle(color: AurumColors.textMuted),
        ),
      );
    }

    final int pointCount = widget.series.first.values.length;
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (final s in widget.series) {
      for (final v in s.values) {
        if (v < minY) minY = v;
        if (v > maxY) maxY = v;
      }
    }

    if (minY == double.infinity || maxY == -double.infinity) {
      minY = 0.0;
      maxY = 100.0;
    }

    // Đệm 10% ở đỉnh và đáy
    final double range = (maxY - minY).abs();
    final double paddedMin = math.max(0.0, minY - (range * 0.05));
    final double paddedMax = maxY + (range * 0.10);

    // Mặc định chọn cột cuối cùng (năm mới nhất) nếu chưa tương tác
    final int activeIdx = (_hoveredIndex ?? (pointCount - 1)).clamp(
      0,
      pointCount - 1,
    );
    final String activeXLabel = activeIdx < widget.xLabels.length
        ? widget.xLabels[activeIdx]
        : 'Năm $activeIdx';

    return Container(
      decoration: BoxDecoration(
        color: AurumColors.bgPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AurumColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tiêu đề biểu đồ & Chú thích Legend
          if (widget.title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title!,
                        style: const TextStyle(
                          color: AurumColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: const TextStyle(
                            color: AurumColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Chú thích các chuỗi (Legend)
                Wrap(
                  spacing: 10,
                  children: widget.series.map((s) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 3,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s.name,
                          style: const TextStyle(
                            color: AurumColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // 2. Thanh HUD Số Liệu Trực Quan Theo Từng Cột Năm (Interactive Year Inspector HUD)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AurumColors.bgCardElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isInteracting
                    ? AurumColors.goldBright.withValues(alpha: 0.8)
                    : AurumColors.borderGold.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Huy hiệu năm đang chọn
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AurumColors.goldDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AurumColors.gold),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 12,
                        color: AurumColors.goldBright,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activeXLabel,
                        style: const TextStyle(
                          color: AurumColors.goldBright,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Danh sách số liệu chi tiết của từng đường trong năm đó
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.series.map((s) {
                        final val = activeIdx < s.values.length
                            ? s.values[activeIdx]
                            : 0.0;
                        final formatted = widget.yFormatter != null
                            ? widget.yFormatter!(val)
                            : val.toStringAsFixed(1);
                        return Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: s.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${s.name}: ',
                                style: TextStyle(
                                  color: s.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                formatted,
                                style: const TextStyle(
                                  color: AurumColors.textPrimary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (_isInteracting)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isInteracting = false;
                        _hoveredIndex = pointCount - 1;
                        _touchX = null;
                      });
                    },
                    child: const Tooltip(
                      message: 'Đặt lại về năm gần nhất',
                      child: Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.refresh,
                          size: 14,
                          color: AurumColors.textMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Vùng vẽ Canvas chính có hỗ trợ MouseRegion (Web/Desktop) & GestureDetector (Mobile Touch)
          SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double height = constraints.maxHeight;

                return MouseRegion(
                  cursor: SystemMouseCursors.precise,
                  onHover: (event) =>
                      _handleTouch(event.localPosition.dx, width, pointCount),
                  onEnter: (event) =>
                      _handleTouch(event.localPosition.dx, width, pointCount),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (details) => _handleTouch(
                      details.localPosition.dx,
                      width,
                      pointCount,
                    ),
                    onPanStart: (details) => _handleTouch(
                      details.localPosition.dx,
                      width,
                      pointCount,
                    ),
                    onPanUpdate: (details) => _handleTouch(
                      details.localPosition.dx,
                      width,
                      pointCount,
                    ),
                    onTapDown: (details) => _handleTouch(
                      details.localPosition.dx,
                      width,
                      pointCount,
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(width, height),
                          painter: _BezierChartPainter(
                            series: widget.series,
                            minY: paddedMin,
                            maxY: paddedMax,
                            pointCount: pointCount,
                            hoveredIndex: activeIdx,
                            xLabels: widget.xLabels,
                            yFormatter: widget.yFormatter,
                          ),
                        ),
                        // Tooltip nổi bám theo vị trí chạm
                        if (_isInteracting &&
                            _touchX != null &&
                            activeIdx < pointCount)
                          _buildFloatingTooltip(width, height, activeIdx),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleTouch(double localX, double totalWidth, int pointCount) {
    if (pointCount < 2) return;
    const double leftPadding = 45.0;
    const double rightPadding = 12.0;
    final double plotWidth = totalWidth - leftPadding - rightPadding;

    final double relativeX = (localX - leftPadding).clamp(0.0, plotWidth);
    final double fraction = relativeX / plotWidth;
    final int index = (fraction * (pointCount - 1)).round().clamp(
      0,
      pointCount - 1,
    );

    if (_hoveredIndex != index || !_isInteracting) {
      HapticHelper.selectionClick();
      setState(() {
        _hoveredIndex = index;
        _touchX = leftPadding + (index / (pointCount - 1)) * plotWidth;
        _isInteracting = true;
      });
    }
  }

  Widget _buildFloatingTooltip(double totalWidth, double totalHeight, int idx) {
    final String xLabel = idx < widget.xLabels.length
        ? widget.xLabels[idx]
        : 'Năm $idx';

    // Đặt vị trí tooltip thông minh tránh tràn màn hình
    final bool isRightSide = (_touchX ?? 0) > (totalWidth / 2);
    final double leftPos = isRightSide ? (_touchX! - 165) : (_touchX! + 14);

    return Positioned(
      top: 10,
      left: leftPos.clamp(10.0, totalWidth - 175),
      child: IgnorePointer(
        child: Container(
          width: 160,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AurumColors.bgCardElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AurumColors.goldBright, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.circle,
                    color: AurumColors.goldBright,
                    size: 8,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    xLabel,
                    style: const TextStyle(
                      color: AurumColors.goldBright,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Divider(height: 10, color: AurumColors.borderSubtle),
              ...widget.series.map((s) {
                if (idx >= s.values.length) return const SizedBox.shrink();
                final val = s.values[idx];
                final formatted = widget.yFormatter != null
                    ? widget.yFormatter!(val)
                    : val.toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.name,
                        style: TextStyle(
                          color: s.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        formatted,
                        style: const TextStyle(
                          color: AurumColors.textPrimary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _BezierChartPainter extends CustomPainter {
  final List<AurumChartSeries> series;
  final double minY;
  final double maxY;
  final int pointCount;
  final int? hoveredIndex;
  final List<String> xLabels;
  final String Function(double)? yFormatter;

  _BezierChartPainter({
    required this.series,
    required this.minY,
    required this.maxY,
    required this.pointCount,
    required this.hoveredIndex,
    required this.xLabels,
    required this.yFormatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 45.0;
    const double rightPad = 12.0;
    const double topPad = 12.0;
    const double bottomPad = 26.0;

    final double plotWidth = size.width - leftPad - rightPad;
    final double plotHeight = size.height - topPad - bottomPad;

    if (plotWidth <= 0 || plotHeight <= 0 || pointCount < 2) return;

    // 1. Vẽ lưới ngang & Nhãn trục Y
    final gridPaint = Paint()
      ..color = AurumColors.border.withValues(alpha: 0.5)
      ..strokeWidth = 0.6;

    const int ySegments = 4;
    for (int i = 0; i <= ySegments; i++) {
      final double y = topPad + (plotHeight / ySegments) * i;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );

      final double val = maxY - ((maxY - minY) / ySegments) * i;
      final String label = yFormatter != null
          ? yFormatter!(val)
          : val.toStringAsFixed(0);

      final textSpan = TextSpan(
        text: label,
        style: const TextStyle(color: AurumColors.textMuted, fontSize: 9),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 6, y - tp.height / 2));
    }

    // 2. Vẽ dải cột dọc Highlight (Golden Column Strip) cho năm đang chọn
    if (hoveredIndex != null && hoveredIndex! < pointCount) {
      final double crosshairX =
          leftPad + (hoveredIndex! / (pointCount - 1)) * plotWidth;
      final double colWidth = math.max(
        18.0,
        plotWidth / (pointCount - 1) * 0.85,
      );
      final double colLeft = (crosshairX - colWidth / 2).clamp(
        leftPad,
        size.width - rightPad - colWidth,
      );

      // Dải cột phát sáng dọc từ trên xuống
      final Rect colRect = Rect.fromLTWH(colLeft, topPad, colWidth, plotHeight);
      final colPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AurumColors.gold.withValues(alpha: 0.18),
            AurumColors.gold.withValues(alpha: 0.03),
          ],
        ).createShader(colRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(colRect, const Radius.circular(5)),
        colPaint,
      );

      // Viền dải cột mảnh
      final colBorderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AurumColors.goldBright.withValues(alpha: 0.35);
      canvas.drawRRect(
        RRect.fromRectAndRadius(colRect, const Radius.circular(5)),
        colBorderPaint,
      );

      // Đường kẻ chỉ dọc tâm cột
      final crosshairPaint = Paint()
        ..color = AurumColors.goldBright.withValues(alpha: 0.85)
        ..strokeWidth = 1.0;

      canvas.drawLine(
        Offset(crosshairX, topPad),
        Offset(crosshairX, size.height - bottomPad),
        crosshairPaint,
      );
    }

    // 3. Vẽ đường cong Bezier cho từng chuỗi
    for (final s in series) {
      if (s.values.length < 2) continue;

      final path = Path();
      final fillPath = Path();

      final List<Offset> points = [];
      for (int i = 0; i < s.values.length; i++) {
        final double x = leftPad + (i / (pointCount - 1)) * plotWidth;
        final double normY = (s.values[i] - minY) / (maxY - minY);
        final double y = topPad + plotHeight * (1.0 - normY.clamp(0.0, 1.0));
        points.add(Offset(x, y));
      }

      path.moveTo(points[0].dx, points[0].dy);
      fillPath.moveTo(points[0].dx, topPad + plotHeight);
      fillPath.lineTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final double controlX = (p0.dx + p1.dx) / 2;

        path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
        fillPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      }

      fillPath.lineTo(points.last.dx, topPad + plotHeight);
      fillPath.close();

      // Đổ bóng chuyển sắc nếu chuỗi hỗ trợ
      if (s.showGradientFill) {
        final fillPaint = Paint()
          ..shader = LinearGradient(
            colors: [
              s.color.withValues(alpha: 0.25),
              s.color.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(leftPad, topPad, plotWidth, plotHeight));
        canvas.drawPath(fillPath, fillPaint);
      }

      // Vẽ đường kẻ
      final linePaint = Paint()
        ..color = s.color
        ..strokeWidth = s.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (s.isDashed) {
        _drawDashedPath(canvas, path, linePaint, dashLength: 6, gapLength: 4);
      } else {
        canvas.drawPath(path, linePaint);
      }
    }

    // 4. Vẽ các điểm tròn phát sáng (Glow Nodes) tại vị trí cột đang chọn
    if (hoveredIndex != null && hoveredIndex! < pointCount) {
      final double crosshairX =
          leftPad + (hoveredIndex! / (pointCount - 1)) * plotWidth;

      for (final s in series) {
        if (hoveredIndex! >= s.values.length) continue;
        final double normY = (s.values[hoveredIndex!] - minY) / (maxY - minY);
        final double y = topPad + plotHeight * (1.0 - normY.clamp(0.0, 1.0));

        final haloPaint = Paint()..color = s.color.withValues(alpha: 0.35);
        final glowPaint = Paint()..color = Colors.white;
        final dotPaint = Paint()..color = s.color;

        canvas.drawCircle(Offset(crosshairX, y), 8.0, haloPaint);
        canvas.drawCircle(Offset(crosshairX, y), 5.5, glowPaint);
        canvas.drawCircle(Offset(crosshairX, y), 3.8, dotPaint);
      }
    }

    // 5. Vẽ nhãn trục X & Tag năm nổi bật tại cột đang chọn
    final int step = math.max(1, (pointCount / 6).floor());
    for (int i = 0; i < pointCount; i += step) {
      if (i >= xLabels.length) break;
      final double x = leftPad + (i / (pointCount - 1)) * plotWidth;
      final bool isHovered = hoveredIndex == i;

      if (isHovered) {
        // Tag năm màu vàng rực ở trục hoành
        final textSpan = TextSpan(
          text: xLabels[i],
          style: const TextStyle(
            color: Color(0xFF07090E),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)
          ..layout();
        final Rect tagR = Rect.fromCenter(
          center: Offset(x, size.height - bottomPad + 13),
          width: tp.width + 10,
          height: tp.height + 4,
        );
        final tagPaint = Paint()..color = AurumColors.goldBright;
        canvas.drawRRect(
          RRect.fromRectAndRadius(tagR, const Radius.circular(4)),
          tagPaint,
        );
        tp.paint(canvas, Offset(tagR.left + 5, tagR.top + 2));
      } else {
        final textSpan = TextSpan(
          text: xLabels[i].length > 4 ? xLabels[i].substring(0, 4) : xLabels[i],
          style: const TextStyle(
            color: AurumColors.textSecondary,
            fontSize: 9.5,
          ),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)
          ..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomPad + 6));
      }
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    double dashLength = 5,
    double gapLength = 3,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = math.min(distance + dashLength, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BezierChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.series != series ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY;
  }
}
