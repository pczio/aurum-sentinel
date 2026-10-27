import '../../domain/engines/arbitrage_engine.dart';
import '../../domain/engines/dip_signal_engine.dart';
import '../../domain/engines/gold_price_curve.dart';
import '../../domain/engines/macro_valuation_engine.dart';
import '../../domain/models/arbitrage_result.dart';
import '../../domain/models/dip_signal_models.dart';
import '../../domain/models/gemini_advisory_signal.dart';
import '../../domain/models/gold_price_snapshot.dart';
import '../../domain/models/macro_indicators.dart';
import '../services/fred_api_service.dart';
import '../services/gemini_advisor_service.dart';
import '../services/gold_feed_service.dart';
import '../services/local_storage_service.dart';

/// Kho dữ liệu trung tâm về Thị Trường Vàng & Tín hiệu Định lượng
class GoldMarketRepository {
  final GoldFeedService _feedService;
  final FredApiService _fredService;
  final GeminiAdvisorService _geminiService;
  final LocalStorageService _storageService;

  GoldMarketRepository({
    required GoldFeedService feedService,
    required FredApiService fredService,
    required GeminiAdvisorService geminiService,
    required LocalStorageService storageService,
  })  : _feedService = feedService,
        _fredService = fredService,
        _geminiService = geminiService,
        _storageService = storageService;

  /// Lấy ảnh chụp giá vàng hiện hành
  GoldPriceSnapshot get currentSnapshot => _feedService.currentSnapshot;

  /// Lấy danh sách thương hiệu trong nước
  List<GoldBrandPrice> get brandPrices => _feedService.fetchBrandPrices();

  /// Lấy đường cong giá lịch sử (đã đồng bộ với cấu hình hoặc CSV người dùng)
  GoldPriceCurve getGoldPriceCurve() {
    final prices = _storageService.loadHistoricalPrices();
    return GoldPriceCurve(prices);
  }

  /// Tính toán chỉ số chênh lệch Arbitrage ASI hiện tại
  ArbitrageResult calculateCurrentAsi({double taxAndFee = 0.0}) {
    final snap = currentSnapshot;
    return ArbitrageEngine.calculateAsi(
      xauUsd: snap.xauUsd,
      usdVnd: snap.usdVnd,
      sjcSellPrice: snap.sjcSellPerLuong,
      taxAndFee: taxAndFee,
    );
  }

  /// Tính toán định giá vĩ mô XAU Fair Value
  Future<MacroIndicators> evaluateMacroIndicators({String fredApiKey = ''}) async {
    final snap = currentSnapshot;
    final double tips = await _fredService.fetchTips10Y(fredApiKey);

    return MacroValuationEngine.evaluateMacroFairValue(
      tips10Y: tips,
      dxy: 104.2,
      cbNetBuyTons: 48.5,
      marketPriceXau: snap.xauUsd,
    );
  }

  /// Đánh giá nhịp giảm và tín hiệu bắt đáy (Dip-Buying)
  DipSignal evaluateCurrentDip({required double monthlyDcaBudget}) {
    final recentPrices = _feedService.fetchRecent30DaysPrices();
    return DipSignalEngine.evaluateDip(
      recentPrices: recentPrices,
      currentPrice: currentSnapshot.ringSellPerChi,
      regularMonthlyDcaBudget: monthlyDcaBudget,
    );
  }

  /// Phân tích thị trường 360 độ từ Gemini AI
  Future<GeminiAdvisorySignal> requestAiAdvisory({
    required String geminiApiKey,
    required MacroIndicators macro,
    required ArbitrageResult arbitrage,
    required DipSignal dipSignal,
  }) async {
    return _geminiService.analyzeMarket(
      apiKey: geminiApiKey,
      snapshot: currentSnapshot,
      macro: macro,
      arbitrage: arbitrage,
      dipSignal: dipSignal,
    );
  }

  /// Cập nhật giá vàng thủ công
  void updateManualSnapshot({
    required double xauUsd,
    required double usdVnd,
    required double sjcSellPerLuong,
    required double ringSellPerChi,
  }) {
    _feedService.updateManualPrices(
      xauUsd: xauUsd,
      usdVnd: usdVnd,
      sjcSellPerLuong: sjcSellPerLuong,
      ringSellPerChi: ringSellPerChi,
    );
  }

  /// Sinh tick giá vi mô
  GoldPriceSnapshot tick() => _feedService.tickSimulate();
}
