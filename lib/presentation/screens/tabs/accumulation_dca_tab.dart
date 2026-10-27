import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/gold_unit_converter.dart';
import '../../../domain/models/accumulation_models.dart';
import '../../controllers/accumulation_controller.dart';
import '../../widgets/cards/aurum_stat_card.dart';
import '../../widgets/charts/aurum_bezier_chart.dart';
import '../../widgets/common/aurum_currency_input.dart';
import '../../widgets/common/aurum_data_table.dart';
import '../../widgets/common/aurum_segmented_pill.dart';
import '../../widgets/common/aurum_slider_field.dart';

/// Tab 2: Tích Sản Lãi Kép Vàng (Gold Wealth Accumulation Dashboard)
class AccumulationDcaTab extends StatelessWidget {
  final AccumulationController controller;

  const AccumulationDcaTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final config = controller.config;
        final histResults = controller.historicalResults;
        final futResults = controller.futureResults;

        // Lấy kết quả mức đang chọn (mặc định 20% = 3 triệu/tháng)
        final SimulationResult activeHist = histResults.firstWhere(
          (r) => r.levelPct == controller.selectedLevel,
          orElse: () => histResults.isNotEmpty
              ? histResults.first
              : const SimulationResult(levelPct: 20, points: []),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Ô nhập Thu nhập hàng tháng (Mặc định 15 triệu VNĐ)
              AurumCurrencyInput(
                label: 'Thu Nhập Hàng Tháng (Lương Cơ Bản)',
                initialValue: config.monthlyIncome,
                quickPresets: const [
                  10000000,
                  15000000,
                  20000000,
                  30000000,
                  50000000,
                ],
                onChanged: (val) {
                  controller.updateConfig(monthlyIncome: val);
                },
              ),
              const SizedBox(height: 14),

              // 2. Chọn mức tích lũy trích lương (% NAV hàng tháng)
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 4,
                children: [
                  const Text(
                    'Mức Trích Mua Vàng Hàng Tháng:',
                    style: TextStyle(
                      color: AurumColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${controller.selectedLevel}% lương = ${CurrencyFormatter.fmtVnd(config.monthlyIncome * (controller.selectedLevel / 100.0))}/tháng',
                    style: const TextStyle(
                      color: AurumColors.goldBright,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: config.levelsPct.map((level) {
                  final bool isSelected = (level == controller.selectedLevel);
                  final Color color =
                      AurumColors.levelColors[config.levelsPct.indexOf(level) %
                          AurumColors.levelColors.length];

                  return ChoiceChip(
                    label: Text('$level%'),
                    selected: isSelected,
                    selectedColor: color.withOpacity(0.25),
                    backgroundColor: AurumColors.bgPanel,
                    labelStyle: TextStyle(
                      color: isSelected ? color : AurumColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? color : AurumColors.border,
                    ),
                    onSelected: (_) => controller.setSelectedLevel(level),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // 3. Thanh chuyển đổi chế độ xem: Lịch Sử / Tương Lai / Bảng So Sánh
              AurumSegmentedPill<AccumulationViewMode>(
                items: const [
                  SegmentItem(
                    value: AccumulationViewMode.historical,
                    label: 'Lịch Sử (2006-Nay)',
                    icon: Icons.history,
                  ),
                  SegmentItem(
                    value: AccumulationViewMode.future,
                    label: 'Dự Phóng Tương Lai',
                    icon: Icons.trending_up,
                  ),
                  SegmentItem(
                    value: AccumulationViewMode.comparison,
                    label: 'Bảng So Sánh',
                    icon: Icons.table_chart_outlined,
                  ),
                ],
                selectedValue: controller.viewMode,
                onSelected: (mode) => controller.setViewMode(mode),
              ),
              const SizedBox(height: 14),

              // 4. Thống kê KPI tóm tắt theo mức đang chọn
              Row(
                children: [
                  Expanded(
                    child: AurumStatCard(
                      title: 'Đã tích lũy (${config.historyStartYear}-nay)',
                      value: GoldUnitConverter.fmtChi(
                        activeHist.totalChi,
                        decimals: 1,
                      ),
                      subtitle:
                          'Trị giá: ${CurrencyFormatter.fmtVnd(activeHist.totalValue)}',
                      accentColor: AurumColors.gold,
                      icon: Icons.savings_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AurumStatCard(
                      title: 'Lãi suất kép lịch sử',
                      value: '+${activeHist.gainPct.toStringAsFixed(0)}%',
                      subtitle:
                          'Vốn: ${CurrencyFormatter.fmtVnd(activeHist.totalInvested)}',
                      accentColor: AurumColors.emerald,
                      icon: Icons.auto_graph,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 5. Nội dung hiển thị theo chế độ
              if (controller.viewMode == AccumulationViewMode.historical) ...[
                _buildHistoricalChart(histResults, config.historyStartYear),
              ] else if (controller.viewMode ==
                  AccumulationViewMode.future) ...[
                _buildFutureControlsAndChart(futResults, config),
              ] else ...[
                AurumDataTable(
                  historicalResults: histResults,
                  futureResults: futResults,
                  futureYears: config.futureYears,
                ),
              ],
              const SizedBox(height: 16),

              // 6. Nút Xuất CSV toàn bộ chuỗi số liệu tài chính
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _exportCsv(context),
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Xuất Dữ Liệu Tháng-Theo-Tháng Ra CSV'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AurumColors.goldBright,
                    side: const BorderSide(color: AurumColors.borderGold),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoricalChart(List<SimulationResult> results, int startYear) {
    if (results.isEmpty) return const SizedBox.shrink();

    final List<AurumChartSeries> seriesList = [];
    final List<String> xLabels = results.first.points
        .map((p) => p.label)
        .toList();

    for (int i = 0; i < results.length; i++) {
      final res = results[i];
      final color = AurumColors.levelColors[i % AurumColors.levelColors.length];
      seriesList.add(
        AurumChartSeries(
          name: '${res.levelPct}%',
          color: color,
          values: res.points.map((p) => p.cumulativeChi).toList(),
          strokeWidth: res.levelPct == controller.selectedLevel ? 3.2 : 1.8,
          showGradientFill: res.levelPct == controller.selectedLevel,
        ),
      );
    }

    return AurumBezierChart(
      title: 'Số Chỉ Vàng Lũy Kế Theo Năm ($startYear → Nay)',
      subtitle: 'Dựa trên giá thực tế từng năm · Rê ngón tay để xem chi tiết',
      series: seriesList,
      xLabels: xLabels,
      yFormatter: (val) => '${val.toStringAsFixed(1)} chỉ',
      height: 250,
    );
  }

  Widget _buildFutureControlsAndChart(
    List<SimulationResult> results,
    dynamic config,
  ) {
    if (results.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Thanh trượt số năm & CAGR
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AurumColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AurumColors.border),
          ),
          child: Column(
            children: [
              AurumSliderField(
                label: 'Số Năm Dự Phóng Tương Lai',
                value: config.futureYears.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                displayValue: '${config.futureYears} năm',
                onChanged: (val) =>
                    controller.updateConfig(futureYears: val.round()),
              ),
              const SizedBox(height: 8),
              AurumSliderField(
                label: 'Tăng Trưởng Giá Vàng Kỳ Vọng (CAGR)',
                value: config.futureCagrPct,
                min: 1,
                max: 25,
                divisions: 48,
                displayValue: '${config.futureCagrPct.toStringAsFixed(1)}%/năm',
                onChanged: (val) => controller.updateConfig(futureCagrPct: val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Biểu đồ dự phóng tương lai lãi kép
        Builder(
          builder: (context) {
            final List<AurumChartSeries> seriesList = [];
            final List<String> xLabels = results.first.points
                .map((p) => p.label)
                .toList();

            for (int i = 0; i < results.length; i++) {
              final res = results[i];
              final color =
                  AurumColors.levelColors[i % AurumColors.levelColors.length];
              seriesList.add(
                AurumChartSeries(
                  name: '${res.levelPct}%',
                  color: color,
                  values: res.points.map((p) => p.cumulativeValue).toList(),
                  strokeWidth: res.levelPct == controller.selectedLevel
                      ? 3.0
                      : 1.8,
                  showGradientFill: res.levelPct == controller.selectedLevel,
                ),
              );
            }

            // Thêm đường Vốn đã bỏ ra đối chứng cho mức đang chọn
            final activeRes = results.firstWhere(
              (r) => r.levelPct == controller.selectedLevel,
              orElse: () => results.first,
            );
            seriesList.add(
              AurumChartSeries(
                name: 'Vốn gốc',
                color: AurumColors.textMuted,
                values: activeRes.points
                    .map((p) => p.cumulativeInvested)
                    .toList(),
                isDashed: true,
                strokeWidth: 1.4,
              ),
            );

            return AurumBezierChart(
              title:
                  'Dự Phóng Giá Trị Tài Sản Lãi Kép (${config.futureYears} Năm Tới)',
              subtitle:
                  'Kỳ vọng tăng giá ${config.futureCagrPct}%/năm · Chạm để xem số liệu',
              series: seriesList,
              xLabels: xLabels,
              yFormatter: (val) => CurrencyFormatter.fmtVnd(val),
              height: 250,
            );
          },
        ),
      ],
    );
  }

  void _exportCsv(BuildContext context) {
    final csvContent = controller.exportToCsv();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AurumColors.bgCardElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AurumColors.emerald),
            SizedBox(width: 8),
            Text(
              'Xuất CSV Thành Công',
              style: TextStyle(color: AurumColors.textPrimary, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Toàn bộ chuỗi số liệu mô phỏng tháng-theo-tháng đã được khởi tạo chuẩn hóa (UTF-8).',
              style: TextStyle(color: AurumColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Container(
              height: 110,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AurumColors.bgPanel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AurumColors.border),
              ),
              child: SingleChildScrollView(
                child: Text(
                  csvContent.split('\n').take(8).join('\n'),
                  style: const TextStyle(
                    color: AurumColors.goldDim,
                    fontSize: 9.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AurumColors.gold),
            child: const Text(
              'Đóng',
              style: TextStyle(
                color: Color(0xFF141002),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
