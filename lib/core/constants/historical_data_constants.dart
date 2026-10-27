/// Bảng dữ liệu giá vàng lịch sử Việt Nam tham chiếu (2006 - 2026)
/// Đơn vị: VNĐ / chỉ (vàng nhẫn trơn 9999).
class HistoricalDataConstants {
  HistoricalDataConstants._();

  /// Bảng giá bình quân năm tham chiếu tổng hợp từ báo cáo thị trường SJC/PNJ/DOJI
  static const Map<int, double> defaultHistoricalPrices = {
    2006: 1150000.0,
    2007: 1450000.0,
    2008: 1780000.0,
    2009: 2180000.0,
    2010: 2920000.0,
    2011: 4350000.0,
    2012: 4450000.0,
    2013: 3650000.0,
    2014: 3540000.0,
    2015: 3320000.0,
    2016: 3600000.0,
    2017: 3620000.0,
    2018: 3680000.0,
    2019: 4200000.0,
    2020: 5600000.0,
    2021: 5650000.0,
    2022: 5550000.0,
    2023: 6150000.0,
    2024: 7600000.0,
    2025: 11800000.0,
    2026: 14880000.0,
  };

  /// 3 Kịch bản tăng trưởng giá vàng phục vụ kế hoạch dự phóng tài chính
  static const Map<String, Map<String, dynamic>> defaultScenarios = {
    'bearish': {
      'id': 'bearish',
      'label': 'Thận trọng (Bearish)',
      'cagr': 3.0,
      'colorValue': 0xFFFF453A,
      'note':
          'Goldman Sachs & Deutsche Bank nhận định Fed giữ lãi suất cao; vàng đi ngang hoặc tăng chậm sau nhịp điều chỉnh.',
    },
    'base': {
      'id': 'base',
      'label': 'Trung tính (Base Case)',
      'cagr': 9.0,
      'colorValue': 0xFFE6B94D,
      'note':
          'Hội đồng Vàng Thế giới (WGC) & khảo sát NHTW kỳ vọng 5.000–6.000 USD/oz. Tăng trưởng phù hợp với chu kỳ dài hạn.',
    },
    'bullish': {
      'id': 'bullish',
      'label': 'Lạc quan (Bullish)',
      'cagr': 16.0,
      'colorValue': 0xFF00E676,
      'note':
          'JPMorgan & Bank of America dự báo mục tiêu 6.000 USD/oz. Lực mua ròng NHTW khổng lồ, căng thẳng địa chính trị.',
    },
  };
}
