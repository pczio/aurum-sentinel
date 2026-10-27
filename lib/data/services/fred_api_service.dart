import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/market_constants.dart';

/// Dịch vụ kết nối Cục Dự trữ Liên bang Mỹ FRED API
class FredApiService {
  final http.Client _client;

  FredApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Lấy lãi suất thực 10 năm TIPS (Mã DFII10)
  Future<double> fetchTips10Y(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      return MarketConstants.defaultTips10Y;
    }

    try {
      final url = Uri.parse(
        'https://api.stlouisfed.org/fred/series/observations?series_id=DFII10&api_key=$apiKey&file_type=json&sort_order=desc&limit=1',
      );
      final response = await _client.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic>? obs = data['observations'] as List<dynamic>?;
        if (obs != null && obs.isNotEmpty) {
          final String? valStr = obs.first['value'] as String?;
          final double? val = double.tryParse(valStr ?? '');
          if (val != null) return val;
        }
      }
    } catch (_) {}

    return MarketConstants.defaultTips10Y;
  }
}
