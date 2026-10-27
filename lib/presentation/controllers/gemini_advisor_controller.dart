import 'package:flutter/material.dart';
import '../../data/repositories/gold_market_repository.dart';
import '../../data/services/android_notification_service.dart';
import '../../domain/models/dip_signal_models.dart';
import '../../domain/models/gemini_advisory_signal.dart';

/// Bộ điều khiển phân hệ Cố Vấn Tài Chính Gemini AI & Radar Bắt Đáy
class GeminiAdvisorController extends ChangeNotifier {
  final GoldMarketRepository _repository;

  GeminiAdvisorySignal? _currentSignal;
  DipSignal? _currentDip;
  bool _isLoadingAi = false;
  String? _errorMessage;

  GeminiAdvisorController(this._repository) {
    evaluateDipSignal(regularMonthlyDcaBudget: 3000000.0); // 20% của 15 triệu
    requestAdvisory(geminiApiKey: '');
  }

  GeminiAdvisorySignal? get currentSignal => _currentSignal;
  DipSignal? get currentDip => _currentDip;
  bool get isLoadingAi => _isLoadingAi;
  String? get errorMessage => _errorMessage;

  /// Đánh giá nhịp giảm giá (Dip-Buying Radar)
  void evaluateDipSignal({required double regularMonthlyDcaBudget}) {
    _currentDip = _repository.evaluateCurrentDip(monthlyDcaBudget: regularMonthlyDcaBudget);
    
    // Nếu phát hiện nhịp giảm mạnh, tự động kích hoạt thông báo Android
    if (_currentDip != null && _currentDip!.isDip && _currentDip!.severity != DipSeverity.none) {
      AndroidNotificationService.instance.notifyAiSignal(
        title: 'RADAR BẮT ĐÁY: ${_currentDip!.title}',
        message: 'Gợi ý giải ngân: ${_currentDip!.suggestedBuyVnd.toStringAsFixed(0)} đ (${_currentDip!.extraBudgetMultiplier}x)',
      );
    }

    notifyListeners();
  }

  /// Gửi yêu cầu phân tích tới Gemini AI
  Future<void> requestAdvisory({required String geminiApiKey}) async {
    _isLoadingAi = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final macro = await _repository.evaluateMacroIndicators();
      final arbitrage = _repository.calculateCurrentAsi();
      final dip = _currentDip ?? _repository.evaluateCurrentDip(monthlyDcaBudget: 3000000.0);

      _currentSignal = await _repository.requestAiAdvisory(
        geminiApiKey: geminiApiKey,
        macro: macro,
        arbitrage: arbitrage,
        dipSignal: dip,
      );

      // Nếu tín hiệu có độ tin cậy cao (>= 85%), bắn thông báo ưu tiên Android
      if (_currentSignal != null && _currentSignal!.isHighPriorityAlert) {
        AndroidNotificationService.instance.notifyAiSignal(
          title: 'GEMINI AI: ${_currentSignal!.signalLabel} (${_currentSignal!.confidenceScore}%)',
          message: _currentSignal!.headline,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingAi = false;
      notifyListeners();
    }
  }
}
