import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/gold_unit_converter.dart';
import '../../controllers/scenario_controller.dart';
import '../../widgets/cards/aurum_stat_card.dart';
import '../../widgets/charts/aurum_bezier_chart.dart';
import '../../widgets/common/aurum_slider_field.dart';

/// Tab 3: Kịch Bản Dự Báo 2026 & Phân Tích Mô Phỏng Monte Carlo
class ScenarioForecastTab extends StatelessWidget {
  final ScenarioController controller;

  const ScenarioForecastTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final scenarios = controller.scenarios;
        final results = controller.simulationResults;
        final monteCarlo = controller.monteCarloResult;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin đầu vào cố định
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AurumColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AurumColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Cố Định Đầu Vào', style: TextStyle(color: AurumColors.textMuted, fontSize: 10.5)),
                        const SizedBox(height: 2),
                        Text(
                          '${CurrencyFormatter.fmtVnd(controller.monthlyIncome)}/tháng · Tích lũy ${controller.selectedLevelPct}%',
                          style: const TextStyle(color: AurumColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Text(
                      '${controller.forecastYears} Năm Tới',
                      style: const TextStyle(color: AurumColors.goldBright, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 1. Ma trận 3 thẻ KPI theo 3 kịch bản
              Row(
                children: scenarios.map((sc) {
                  final res = results[sc.id];
                  final valText = res != null ? CurrencyFormatter.fmtVnd(res.finalValue) : '—';
                  final gainText = res != null ? '+${res.gainPct.toStringAsFixed(0)}%' : '—';

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: scenarios.indexOf(sc) == 0 ? 0 : 4,
                        right: scenarios.indexOf(sc) == scenarios.length - 1 ? 0 : 4,
                      ),
                      child: AurumStatCard(
                        title: sc.label.split(' ').first,
                        value: valText,
                        subtitle: '$gainText · ${sc.cagrPct}%',
                        accentColor: sc.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // 2. Biểu đồ so sánh 3 đường kịch bản + đường Vốn gốc
              _buildMultiScenarioChart(scenarios, results, controller),
              const SizedBox(height: 14),

              // 3. Tinh chỉnh CAGR % cho từng kịch bản
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AurumColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AurumColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Điều Chỉnh Tăng Trưởng (CAGR) Từng Kịch Bản',
                      style: TextStyle(color: AurumColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ...scenarios.map((sc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AurumSliderField(
                              label: sc.label,
                              value: sc.cagrPct,
                              min: 1,
                              max: 25,
                              divisions: 48,
                              displayValue: '${sc.cagrPct.toStringAsFixed(1)}%/năm',
                              onChanged: (val) => controller.updateScenarioCagr(sc.id, val),
                            ),
                            Text(
                              sc.note,
                              style: const TextStyle(color: AurumColors.textMuted, fontSize: 10.5, height: 1.3),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. Mô phỏng ngẫu nhiên Monte Carlo (1.000 chu kỳ thử tải)
              if (monteCarlo != null) ...[
                _buildMonteCarloSection(monteCarlo),
                const SizedBox(height: 14),
              ],

              // 5. Bảng so sánh 3 kịch bản
              _buildScenarioTable(scenarios, results),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMultiScenarioChart(
    List<dynamic> scenarios,
    Map<String, dynamic> results,
    ScenarioController controller,
  ) {
    if (results.isEmpty) return const SizedBox.shrink();

    final List<AurumChartSeries> seriesList = [];
    final firstRes = results.values.first;
    final List<String> xLabels = (firstRes.simulation.points as List).map((p) => p.label as String).toList();

    for (final sc in scenarios) {
      final res = results[sc.id];
      if (res != null) {
        seriesList.add(
          AurumChartSeries(
            name: sc.label.split(' ').first,
            color: sc.color,
            values: (res.simulation.points as List).map((p) => p.cumulativeValue as double).toList(),
            strokeWidth: 2.6,
          ),
        );
      }
    }

    // Đường Vốn gốc đã bỏ ra
    seriesList.add(
      AurumChartSeries(
        name: 'Vốn gốc',
        color: AurumColors.textMuted,
        values: (firstRes.simulation.points as List).map((p) => p.cumulativeInvested as double).toList(),
        isDashed: true,
        strokeWidth: 1.5,
      ),
    );

    return AurumBezierChart(
      title: 'So Sánh Đường Đi Tài Sản 3 Kịch Bản (10 Năm)',
      subtitle: 'Đường đứt nét: Vốn đã bỏ ra · Chạm để xem số liệu chi tiết',
      series: seriesList,
      xLabels: xLabels,
      yFormatter: (val) => CurrencyFormatter.fmtVnd(val),
      height: 250,
    );
  }

  Widget _buildMonteCarloSection(dynamic monteCarlo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AurumColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AurumColors.borderGold.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.casino_outlined, color: AurumColors.gold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Kiểm Định Sức Chịu Tải Monte Carlo (1.000 Chu Kỳ)',
                    style: TextStyle(color: AurumColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AurumColors.emerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${monteCarlo.probabilityOfProfit.toStringAsFixed(0)}% Sinh Lời',
                  style: const TextStyle(color: AurumColors.emerald, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Mô phỏng ngẫu nhiên chuyển động Brown hình học (GBM) với độ biến động 16%/năm để tìm phân vị an toàn vốn.',
            style: TextStyle(color: AurumColors.textMuted, fontSize: 11, height: 1.35),
          ),
          const SizedBox(height: 14),

          // 3 Mốc phân vị: P10 (Xấu nhất), P50 (Trung vị), P90 (Tốt nhất)
          Row(
            children: [
              _buildMonteCarloCard('P10 (10% Rủi Ro)', CurrencyFormatter.fmtVnd(monteCarlo.p10Wealth), AurumColors.ruby),
              const SizedBox(width: 8),
              _buildMonteCarloCard('P50 (Kỳ Vọng)', CurrencyFormatter.fmtVnd(monteCarlo.p50Wealth), AurumColors.gold),
              const SizedBox(width: 8),
              _buildMonteCarloCard('P90 (10% Bùng Nổ)', CurrencyFormatter.fmtVnd(monteCarlo.p90Wealth), AurumColors.emerald),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonteCarloCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AurumColors.bgPanel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AurumColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AurumColors.textMuted, fontSize: 9.5)),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 13.5, fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioTable(List<dynamic> scenarios, Map<String, dynamic> results) {
    return Container(
      decoration: BoxDecoration(
        color: AurumColors.bgPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AurumColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bảng So Sánh Chỉ Số 3 Kịch Bản',
            style: TextStyle(color: AurumColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 18,
              headingRowHeight: 34,
              dataRowMinHeight: 38,
              dataRowMaxHeight: 40,
              headingTextStyle: const TextStyle(color: AurumColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
              dataTextStyle: const TextStyle(color: AurumColors.textPrimary, fontSize: 11.5),
              columns: const [
                DataColumn(label: Text('Kịch Bản')),
                DataColumn(label: Text('CAGR')),
                DataColumn(label: Text('Chỉ Tích Lũy')),
                DataColumn(label: Text('Giá Trị Cuối')),
                DataColumn(label: Text('Vốn Gốc')),
                DataColumn(label: Text('Lợi Nhuận')),
              ],
              rows: scenarios.map((sc) {
                final res = results[sc.id];
                if (res == null) return const DataRow(cells: []);

                return DataRow(
                  cells: [
                    DataCell(Text(sc.label.split(' ').first, style: TextStyle(color: sc.color, fontWeight: FontWeight.w700))),
                    DataCell(Text('${sc.cagrPct.toStringAsFixed(1)}%')),
                    DataCell(Text(GoldUnitConverter.fmtChi(res.finalChi, decimals: 1))),
                    DataCell(Text(CurrencyFormatter.fmtVnd(res.finalValue), style: const TextStyle(fontWeight: FontWeight.w700))),
                    DataCell(Text(CurrencyFormatter.fmtVnd(res.totalInvested))),
                    DataCell(Text('+${res.gainPct.toStringAsFixed(0)}%', style: TextStyle(color: sc.color, fontWeight: FontWeight.w800))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
