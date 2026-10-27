import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/gold_market_repository.dart';
import '../../domain/models/arbitrage_result.dart';
import '../../domain/models/gold_price_snapshot.dart';
import '../../domain/models/macro_indicators.dart';

/// Bộ điều khiển phân hệ Thị Trường & Arbitrage SJC
class MarketIntelligenceController extends ChangeNotifier {
  final GoldMarketRepository _repository;

  late GoldPriceSnapshot _snapshot;
  late List<GoldBrandPrice> _brandPrices;
  late ArbitrageResult _arbitrageResult;
  MacroIndicators? _macroIndicators;
  bool _isLoadingMacro = false;
  bool _isAutoTicking = false;
  Timer? _tickerTimer;

  MarketIntelligenceController(this._repository) {
    _snapshot = _repository.currentSnapshot;
    _brandPrices = _repository.brandPrices;
    _arbitrageResult = _repository.calculateCurrentAsi();
    loadMacroData();
  }

  GoldPriceSnapshot get snapshot => _snapshot;
  List<GoldBrandPrice> get brandPrices => _brandPrices;
  ArbitrageResult get arbitrageResult => _arbitrageResult;
  MacroIndicators? get macroIndicators => _macroIndicators;
  bool get isLoadingMacro => _isLoadingMacro;
  bool get isAutoTicking => _isAutoTicking;

  /// Tải dữ liệu vĩ mô và tính toán định giá P*
  Future<void> loadMacroData({String fredApiKey = ''}) async {
    _isLoadingMacro = true;
    notifyListeners();

    try {
      _macroIndicators = await _repository.evaluateMacroIndicators(fredApiKey: fredApiKey);
    } catch (_) {}

    _isLoadingMacro = false;
    notifyListeners();
  }

  /// Cập nhật giá thủ công
  void updateManualPrices({
    required double xauUsd,
    required double usdVnd,
    required double sjcSellPerLuong,
    required double ringSellPerChi,
    double taxAndFee = 0.0,
  }) {
    _repository.updateManualSnapshot(
      xauUsd: xauUsd,
      usdVnd: usdVnd,
      sjcSellPerLuong: sjcSellPerLuong,
      ringSellPerChi: ringSellPerChi,
    );
    _snapshot = _repository.currentSnapshot;
    _brandPrices = _repository.brandPrices;
    _arbitrageResult = _repository.calculateCurrentAsi(taxAndFee: taxAndFee);

    // Tự động tính lại định giá vĩ mô theo giá mới
    if (_macroIndicators != null) {
      _macroIndicators = MacroIndicators(
        tips10Y: _macroIndicators!.tips10Y,
        dxy: _macroIndicators!.dxy,
        cbNetBuyTons: _macroIndicators!.cbNetBuyTons,
        fairValueXau: _macroIndicators!.fairValueXau,
        marketPriceXau: xauUsd,
        updatedAt: DateTime.now(),
      );
    }

    notifyListeners();
  }

  /// Bật / Tắt mô phỏng biến động giá thời gian thực (Live Tick Stream)
  void toggleAutoTick() {
    _isAutoTicking = !_isAutoTicking;
    if (_isAutoTicking) {
      _tickerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _snapshot = _repository.tick();
        _arbitrageResult = _repository.calculateCurrentAsi();
        notifyListeners();
      });
    } else {
      _tickerTimer?.cancel();
      _tickerTimer = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
