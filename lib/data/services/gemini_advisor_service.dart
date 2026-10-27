import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/gemini_advisory_signal.dart';
import '../../domain/models/gold_price_snapshot.dart';
import '../../domain/models/macro_indicators.dart';
import '../../domain/models/arbitrage_result.dart';
import '../../domain/models/dip_signal_models.dart';

/// Dịch vụ kết nối Google Gemini AI phân tích tài chính vĩ mô 360 độ
class GeminiAdvisorService {
  final http.Client _client;

  GeminiAdvisorService({http.Client? client}) : _client = client ?? http.Client();

  /// Gửi dữ liệu thị trường và nhận phân tích có cấu trúc từ Gemini
  Future<GeminiAdvisorySignal> analyzeMarket({
    required String apiKey,
    required GoldPriceSnapshot snapshot,
    required MacroIndicators macro,
    required ArbitrageResult arbitrage,
    required DipSignal dipSignal,
  }) async {
    // Nếu chưa cấu hình API key, dùng bộ định lượng Heuristic Quantitative Engine
    if (apiKey.trim().isEmpty) {
      return _generateHeuristicAdvisory(
        snapshot: snapshot,
        macro: macro,
        arbitrage: arbitrage,
        dipSignal: dipSignal,
      );
    }

    try {
      final endpoint = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      final prompt = _buildFinancialPrompt(
        snapshot: snapshot,
        macro: macro,
        arbitrage: arbitrage,
        dipSignal: dipSignal,
      );

      final response = await _client
          .post(
            endpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.2,
                'responseMimeType': 'application/json',
              }
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final String? textContent =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;

        if (textContent != null && textContent.isNotEmpty) {
          final Map<String, dynamic> jsonParsed = jsonDecode(textContent) as Map<String, dynamic>;
          return _parseGeminiJsonResponse(jsonParsed);
        }
      }
    } catch (_) {
      // Fallback về engine định lượng nội bộ nếu có lỗi kết nối mạng
    }

    return _generateHeuristicAdvisory(
      snapshot: snapshot,
      macro: macro,
      arbitrage: arbitrage,
      dipSignal: dipSignal,
    );
  }

  /// Tạo prompt có cấu trúc JSON chặt chẽ gửi tới Gemini
  String _buildFinancialPrompt({
    required GoldPriceSnapshot snapshot,
    required MacroIndicators macro,
    required ArbitrageResult arbitrage,
    required DipSignal dipSignal,
  }) {
    return '''
Bạn là chuyên gia phân tích định lượng thị trường vàng cấp cao (Chief Gold Strategist & Macro Economist).
Hãy phân tích 12 biến số vĩ mô và kỹ thuật sau đây để đưa ra khuyến nghị đầu tư vàng vật chất & phái sinh:

DỮ LIỆU ĐẦU VÀO:
- Vàng thế giới XAU/USD: \$${snapshot.xauUsd} (Biến động 24h: ${snapshot.xauUsdChange24h}%)
- Lợi suất thực 10 năm Mỹ TIPS (DFII10): ${macro.tips10Y}% (Tương quan nghịch đảo hệ số beta = 0.65)
- Chỉ số sức mạnh USD (DXY): ${macro.dxy}
- Mua ròng vàng NHTW thế giới: ${macro.cbNetBuyTons} tấn/tháng
- Giá trị hợp lý vĩ mô P*: \$${macro.fairValueXau.toStringAsFixed(1)} (Độ lệch định giá: ${macro.gapPercent.toStringAsFixed(1)}%)
- Giá vàng miếng SJC: ${snapshot.sjcSellPerLuong} VND/lượng
- Giá vàng nhẫn trơn 9999: ${snapshot.ringSellPerChi} VND/chỉ
- Chỉ số chênh lệch SJC Arbitrage (ASI): ${arbitrage.asi} VND/lượng (Vùng: ${arbitrage.zone.name})
- Chỉ báo kỹ thuật RSI 14: ${dipSignal.rsi14.toStringAsFixed(1)}
- Độ sụt giảm từ đỉnh 30 ngày: ${dipSignal.drawdownPercent.toStringAsFixed(1)}% (Nhịp giảm: ${dipSignal.severity.name})
- Tỷ giá USD/VND: ${snapshot.usdVnd}

YÊU CẦU ĐẦU RA (Output đúng định dạng JSON thuần, không bọc markdown):
{
  "action_signal": "STRONG_BUY" | "MODERATE_BUY" | "HOLD" | "TRIM" | "SELL",
  "confidence_score": (số nguyên từ 0 đến 100),
  "target_price_usd": (số thực vùng TP kỳ vọng USD/oz),
  "stop_loss_usd": (số thực vùng SL phòng thủ USD/oz),
  "nav_allocation_pct": (số thực % tỷ trọng phân bổ vốn đề xuất),
  "headline": (tiêu đề ngắn gọn 1 câu nêu rõ khuyến nghị),
  "macro_reasoning": (phân tích chi tiết 3-4 câu về tác động của TIPS, DXY, NHTW và chu kỳ tiền tệ),
  "domestic_advice": (lời khuyên cụ thể cho nhà đầu tư Việt Nam: nên mua nhẫn 9999 hay SJC dựa trên chỉ số ASI)
}
''';
  }

  /// Phân giải kết quả JSON trả về từ Gemini
  GeminiAdvisorySignal _parseGeminiJsonResponse(Map<String, dynamic> json) {
    final String rawSignal = (json['action_signal'] as String? ?? 'HOLD').toUpperCase();
    ActionSignal signal = ActionSignal.hold;
    if (rawSignal.contains('STRONG_BUY')) {
      signal = ActionSignal.strongBuy;
    } else if (rawSignal.contains('BUY') || rawSignal.contains('MODERATE_BUY')) {
      signal = ActionSignal.moderateBuy;
    } else if (rawSignal.contains('TRIM')) {
      signal = ActionSignal.trim;
    } else if (rawSignal.contains('SELL')) {
      signal = ActionSignal.sell;
    }

    return GeminiAdvisorySignal(
      signal: signal,
      confidenceScore: (json['confidence_score'] as num?)?.toInt() ?? 80,
      targetPriceUsd: (json['target_price_usd'] as num?)?.toDouble() ?? 4650.0,
      stopLossUsd: (json['stop_loss_usd'] as num?)?.toDouble() ?? 4320.0,
      navAllocationPct: (json['nav_allocation_pct'] as num?)?.toDouble() ?? 20.0,
      headline: json['headline'] as String? ?? 'Chiến lược tích lũy vàng bền vững',
      macroReasoning: json['macro_reasoning'] as String? ??
          'Lợi suất thực TIPS và lực mua ròng của các NHTW tiếp tục hỗ trợ xu hướng tăng dài hạn.',
      domesticAdvice: json['domestic_advice'] as String? ??
          'Ưu tiên vàng nhẫn tròn trơn 9999 để tối ưu hóa biên độ chênh lệch mua bán.',
      generatedAt: DateTime.now(),
      isHeuristicFallback: false,
    );
  }

  /// Bộ phân tích định lượng Heuristic Quantitative Engine độc lập chạy offline
  GeminiAdvisorySignal _generateHeuristicAdvisory({
    required GoldPriceSnapshot snapshot,
    required MacroIndicators macro,
    required ArbitrageResult arbitrage,
    required DipSignal dipSignal,
  }) {
    ActionSignal signal;
    int confidence;
    double navAllocation;
    double tp;
    double sl;
    String headline;
    String macroReasoning;
    String domesticAdvice;

    // Đánh giá đa biến số: Lợi suất thực TIPS + RSI + ASI + Drawdown
    final bool isOversold = dipSignal.rsi14 < 35.0 || dipSignal.drawdownPercent <= -5.0;
    final bool isAsiSafe = arbitrage.asi <= 6000000.0;
    final bool isMacroSupportive = macro.tips10Y < 2.0;

    if (isOversold && isAsiSafe && isMacroSupportive) {
      signal = ActionSignal.strongBuy;
      confidence = 92;
      navAllocation = 25.0;
      tp = snapshot.xauUsd * 1.08;
      sl = snapshot.xauUsd * 0.96;
      headline = 'TÍN HIỆU MUA TÍCH LŨY MẠNH (Độ tin cậy 92%)';
      macroReasoning =
          'Sự hội tụ hiếm gặp giữa vùng quá bán kỹ thuật (RSI ${dipSignal.rsi14.toStringAsFixed(1)}), lợi suất thực TIPS (${macro.tips10Y}%) ở mức thấp và chỉ số chênh lệch ASI (${(arbitrage.asi / 1000000).toStringAsFixed(1)} tr) trong vùng an toàn tạo cơ hội gia tăng tỷ trọng vàng vật chất lý tưởng.';
      domesticAdvice =
          'Giải ngân tăng thêm 25% ngân sách vào nhẫn trơn 9999 (PNJ, DOJI, BTMC) hoặc chia lệnh gom vàng miếng SJC.';
    } else if (isOversold || dipSignal.severity == DipSeverity.mildDip) {
      signal = ActionSignal.moderateBuy;
      confidence = 84;
      navAllocation = 20.0;
      tp = snapshot.xauUsd * 1.06;
      sl = snapshot.xauUsd * 0.97;
      headline = 'MUA TÍCH SẢN ĐỊNH KỲ THEO NHỊP CHỈNH (84%)';
      macroReasoning =
          'Giá vàng đang trong nhịp điều chỉnh kỹ thuật lành mạnh (-${dipSignal.drawdownPercent.abs().toStringAsFixed(1)}% từ đỉnh). Nhu cầu mua ròng của các Ngân hàng Trung ương (${macro.cbNetBuyTons} tấn/tháng) tạo lực cầu sàn vững chắc.';
      domesticAdvice =
          'Duy trì lệnh DCA hàng tháng đúng ngày nhận lương. Ưu tiên nhẫn tròn trơn để tránh rủi ro biến động premium.';
    } else if (snapshot.xauUsdChange24h > 3.0 && arbitrage.asi > 12000000.0) {
      signal = ActionSignal.trim;
      confidence = 88;
      navAllocation = 15.0;
      tp = snapshot.xauUsd * 1.02;
      sl = snapshot.xauUsd * 0.95;
      headline = 'HẠ TỶ TRỌNG NGẮN HẠN — CẢNH BÁO PREMIUM (88%)';
      macroReasoning =
          'Giá vàng trong nước tăng nóng đẩy chỉ số ASI lên mức cao (${(arbitrage.asi / 1000000).toStringAsFixed(1)} tr/lượng). Khả năng cao sẽ xuất hiện nhịp rung lắc kỹ thuật khi áp lực chốt lời gia tăng.';
      domesticAdvice =
          'Tạm ngưng mua đuổi giá đỉnh. Nếu đang có vị thế lướt sóng vàng miếng SJC ngắn hạn, có thể cân nhắc chốt lời một phần.';
    } else {
      signal = ActionSignal.hold;
      confidence = 78;
      navAllocation = 20.0;
      tp = snapshot.xauUsd * 1.05;
      sl = snapshot.xauUsd * 0.96;
      headline = 'NẮM GIỮ DANH MỤC & THEO DÕI BIẾN SỐ VĨ MÔ';
      macroReasoning =
          'Thị trường đang tích lũy quanh vùng định giá hợp lý vĩ mô P* (\$${macro.fairValueXau.toStringAsFixed(0)}). Chỉ số USD DXY (${macro.dxy}) đang đi ngang chờ định hướng chính sách tiền tệ tiếp theo của Fed.';
      domesticAdvice =
          'Tiếp tục giữ nguyên danh mục tích sản, chuẩn bị sẵn sàng hạn mức tiền mặt chờ các nhịp điều chỉnh sâu để giải ngân.';
    }

    return GeminiAdvisorySignal(
      signal: signal,
      confidenceScore: confidence,
      targetPriceUsd: tp,
      stopLossUsd: sl,
      navAllocationPct: navAllocation,
      headline: headline,
      macroReasoning: macroReasoning,
      domesticAdvice: domesticAdvice,
      generatedAt: DateTime.now(),
      isHeuristicFallback: true,
    );
  }
}
