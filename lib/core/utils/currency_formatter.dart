import 'package:intl/intl.dart';

/// Bộ tiện ích định dạng tiền tệ & tỷ suất tài chính
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _exactVnd = NumberFormat('#,##0', 'vi_VN');
  static final NumberFormat _exactUsd = NumberFormat('#,##0.00', 'en_US');

  /// Định dạng tiền Việt Nam:
  /// short=true -> "3,15 tỷ", "15,00 triệu", "450 nghìn", "2.500 đ"
  /// short=false -> "15.000.000 đ"
  static String fmtVnd(double value, {bool short = true}) {
    final String sign = value < 0 ? '-' : '';
    final double absVal = value.abs();

    if (short) {
      if (absVal >= 1000000000) {
        return '$sign${(absVal / 1000000000).toStringAsFixed(2)} tỷ';
      }
      if (absVal >= 1000000) {
        return '$sign${(absVal / 1000000).toStringAsFixed(2)} triệu';
      }
      if (absVal >= 1000) {
        return '$sign${(absVal / 1000).toStringAsFixed(0)} nghìn';
      }
      return '$sign${_exactVnd.format(absVal)} đ';
    }
    return '$sign${_exactVnd.format(absVal)} đ';
  }

  /// Định dạng chi tiết không viết tắt: "148.000.000 đ"
  static String fmtVndExact(double value) {
    return '${value < 0 ? '-' : ''}${_exactVnd.format(value.abs())} đ';
  }

  /// Định dạng USD: "$4,450.50"
  static String fmtUsd(double value) {
    return '\$${_exactUsd.format(value)}';
  }

  /// Định dạng tỷ lệ phần trăm: "+320.5%", "-5.2%"
  static String fmtPercent(double value, {bool showSign = true, int decimals = 1}) {
    final String sign = showSign && value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(decimals)}%';
  }

  /// Trích xuất giá trị số từ chuỗi VNĐ người dùng nhập
  static double parseVnd(String text, double fallback) {
    final String cleaned = text
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('đ', '')
        .replaceAll('VND', '')
        .replaceAll('vnd', '')
        .trim();
    return double.tryParse(cleaned) ?? fallback;
  }

  /// Trích xuất số thực (hỗ trợ cả dấu chấm và dấu phẩy thập phân)
  static double parseFloat(String text, double fallback) {
    final String cleaned = text.replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? fallback;
  }

  /// Trích xuất số nguyên
  static int parseInt(String text, int fallback) {
    final String cleaned = text.replaceAll('.', '').replaceAll(',', '').trim();
    return int.tryParse(cleaned) ?? fallback;
  }

  /// Trích xuất danh sách mức tích lũy từ chuỗi phân cách bởi dấu phẩy "10, 15, 20"
  static List<int> parseLevels(String text, List<int> fallback) {
    try {
      final parts = text.split(',');
      final levels = <int>[];
      for (final p in parts) {
        final val = int.tryParse(p.trim());
        if (val != null && val > 0 && val <= 100) {
          levels.add(val);
        }
      }
      return levels.isNotEmpty ? levels : fallback;
    } catch (_) {
      return fallback;
    }
  }
}
