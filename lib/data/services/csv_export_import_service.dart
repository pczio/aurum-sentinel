import '../../domain/models/accumulation_models.dart';

/// Dịch vụ nhập/xuất tệp dữ liệu CSV chuẩn hóa thuần Dart
class CsvExportImportService {
  CsvExportImportService._();

  /// Xuất toàn bộ chuỗi số liệu mô phỏng Tích sản (Lịch sử & Tương lai) ra chuỗi CSV
  static String exportSimulationToCsv({
    required List<SimulationResult> historicalResults,
    required List<SimulationResult> futureResults,
  }) {
    final buffer = StringBuffer();

    // Tiêu đề cột chuẩn hóa
    buffer.writeln(
      'loai_mo_phong,muc_tich_luy_%,chu_ky,chi_da_mua_trong_ky,chi_luy_ke,gia_tai_ky_vnd,gia_tri_tai_san_luy_ke_vnd,von_da_bo_ra_vnd,lai_lo_vnd,ty_suat_roi_%',
    );

    // Chuỗi lịch sử
    for (final res in historicalResults) {
      for (final p in res.points) {
        buffer.writeln([
          'lich_su',
          res.levelPct,
          p.label,
          p.chiBought.toStringAsFixed(4),
          p.cumulativeChi.toStringAsFixed(4),
          p.pricePerChi.toStringAsFixed(0),
          p.cumulativeValue.toStringAsFixed(0),
          p.cumulativeInvested.toStringAsFixed(0),
          p.profit.toStringAsFixed(0),
          p.gainPercent.toStringAsFixed(2),
        ].join(','));
      }
    }

    // Chuỗi dự phóng tương lai
    for (final res in futureResults) {
      for (final p in res.points) {
        buffer.writeln([
          'du_phong_tuong_lai',
          res.levelPct,
          p.label,
          p.chiBought.toStringAsFixed(4),
          p.cumulativeChi.toStringAsFixed(4),
          p.pricePerChi.toStringAsFixed(0),
          p.cumulativeValue.toStringAsFixed(0),
          p.cumulativeInvested.toStringAsFixed(0),
          p.profit.toStringAsFixed(0),
          p.gainPercent.toStringAsFixed(2),
        ].join(','));
      }
    }

    return buffer.toString();
  }

  /// Trích xuất bảng giá vàng theo năm từ nội dung CSV người dùng nhập
  /// Định dạng mỗi dòng: 'năm,giá_vnd_mỗi_chỉ' (ví dụ: '2006,1150000')
  static Map<int, double> parseHistoricalCsv(String csvContent) {
    final Map<int, double> parsed = {};
    final lines = csvContent.split(RegExp(r'\r?\n'));

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      final parts = line.split(',');
      if (parts.length < 2) continue;

      final yearStr = parts[0].trim();
      final priceStr = parts[1].replaceAll('.', '').replaceAll(',', '').replaceAll('đ', '').trim();

      final int? year = int.tryParse(yearStr);
      final double? price = double.tryParse(priceStr);

      if (year != null && price != null && year >= 1990 && year <= 2050 && price > 0) {
        parsed[year] = price;
      }
    }

    return parsed;
  }

  /// Xuất bảng giá lịch sử hiện hành ra CSV
  static String exportHistoricalPricesToCsv(Map<int, double> prices) {
    final buffer = StringBuffer();
    buffer.writeln('nam,gia_vnd_moi_chi');

    final sortedYears = prices.keys.toList()..sort();
    for (final y in sortedYears) {
      buffer.writeln('$y,${prices[y]!.toStringAsFixed(0)}');
    }

    return buffer.toString();
  }
}
