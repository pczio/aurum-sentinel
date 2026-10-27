import 'package:intl/intl.dart';

/// Bộ định dạng thời gian và nhãn chu kỳ tài chính
class DateFormatter {
  DateFormatter._();

  static final DateFormat _vnDate = DateFormat('dd/MM/yyyy');
  static final DateFormat _vnDateTime = DateFormat('HH:mm - dd/MM/yyyy');
  static final DateFormat _monthYear = DateFormat('MM/yyyy');

  static String formatDate(DateTime dt) => _vnDate.format(dt);
  static String formatDateTime(DateTime dt) => _vnDateTime.format(dt);
  static String formatMonthYear(DateTime dt) => _monthYear.format(dt);
  static String formatIsoMonth(int year, int month) => '$year-${month.toString().padLeft(2, '0')}';
}
