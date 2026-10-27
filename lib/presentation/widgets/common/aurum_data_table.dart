import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/gold_unit_converter.dart';
import '../../../domain/models/accumulation_models.dart';

/// Bảng so sánh tài chính đa cấp độ tích sản
class AurumDataTable extends StatelessWidget {
  final List<SimulationResult> historicalResults;
  final List<SimulationResult> futureResults;
  final int futureYears;

  const AurumDataTable({
    super.key,
    required this.historicalResults,
    required this.futureResults,
    required this.futureYears,
  });

  @override
  Widget build(BuildContext context) {
    if (historicalResults.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AurumColors.bgPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AurumColors.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'So Sánh Các Mức Tích Lũy (% Thu Nhập)',
              style: TextStyle(
                color: AurumColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Bảng cuộn ngang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 18,
              headingRowHeight: 36,
              dataRowMinHeight: 38,
              dataRowMaxHeight: 42,
              headingTextStyle: const TextStyle(
                color: AurumColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              dataTextStyle: const TextStyle(
                color: AurumColors.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              columns: [
                const DataColumn(label: Text('Mức %')),
                const DataColumn(label: Text('Đã Tích Lũy')),
                const DataColumn(label: Text('Giá Trị Hiện Tại')),
                const DataColumn(label: Text('Vốn Bỏ Ra')),
                const DataColumn(label: Text('Lãi Lịch Sử')),
                DataColumn(label: Text('Sau $futureYears Năm')),
              ],
              rows: List.generate(historicalResults.length, (index) {
                final hist = historicalResults[index];
                final fut = index < futureResults.length ? futureResults[index] : null;
                final color = AurumColors.levelColors[index % AurumColors.levelColors.length];

                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${hist.levelPct}%',
                          style: TextStyle(color: color, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    DataCell(Text(GoldUnitConverter.fmtChi(hist.totalChi, decimals: 2))),
                    DataCell(Text(
                      CurrencyFormatter.fmtVnd(hist.totalValue),
                      style: const TextStyle(color: AurumColors.goldBright, fontWeight: FontWeight.w700),
                    )),
                    DataCell(Text(CurrencyFormatter.fmtVnd(hist.totalInvested))),
                    DataCell(Text(
                      '+${hist.gainPct.toStringAsFixed(0)}%',
                      style: const TextStyle(color: AurumColors.emerald, fontWeight: FontWeight.w700),
                    )),
                    DataCell(Text(
                      fut != null ? CurrencyFormatter.fmtVnd(fut.totalValue) : '—',
                      style: const TextStyle(color: AurumColors.textPrimary, fontWeight: FontWeight.w700),
                    )),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
