/// Đường cong giá vàng nội suy theo tháng
/// Cho phép tính toán giá vàng trơn tru giữa các mốc giá theo năm
class GoldPriceCurve {
  final Map<int, double> _prices;
  final List<int> _years;

  GoldPriceCurve(Map<int, double> yearlyPrices)
      : _prices = Map.from(yearlyPrices),
        _years = yearlyPrices.keys.toList()..sort();

  List<int> get years => List.unmodifiable(_years);

  /// Lấy giá vàng tại năm và tháng cụ thể (nội suy tuyến tính theo tiến độ tháng)
  double priceAt(int year, int month) {
    if (_years.isEmpty) return 14880000.0;

    // Giới hạn ngoài khoảng dữ liệu
    if (year < _years.first) {
      return _prices[_years.first]!;
    }
    if (year > _years.last) {
      return _prices[_years.last]!;
    }

    final double base = _prices[year] ?? _prices[_years.first]!;
    final int nextYear = year + 1;

    // Nếu có giá của năm kế tiếp, nội suy theo tiến độ tháng (1..12)
    if (_prices.containsKey(nextYear) && _prices.containsKey(year)) {
      final double nextPrice = _prices[nextYear]!;
      final double monthFraction = (month - 1) / 12.0;
      return base + (nextPrice - base) * monthFraction;
    }

    return base;
  }
}
