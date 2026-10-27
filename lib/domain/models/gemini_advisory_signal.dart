import 'package:flutter/material.dart';
import '../../core/constants/aurum_colors.dart';

enum ActionSignal {
  strongBuy,   // MUA MẠNH / TÍCH LŨY MẠNH
  moderateBuy, // MUA VỪA PHẢI / DCA THƯỜNG NIÊN
  hold,        // GIỮ NGUYÊN DANH MỤC
  trim,        // HẠ TỶ TRỌNG / CHỐT LỜI MỘT PHẦN
  sell,        // CHỐT LỜI / PHÒNG THỦ TIỀN MẶT
}

/// Tín hiệu và khuyến nghị tài chính chuyên sâu từ Gemini AI
@immutable
class GeminiAdvisorySignal {
  final ActionSignal signal;
  final int confidenceScore;      // 0 - 100%
  final double targetPriceUsd;    // Vùng chốt lời kỳ vọng TP (USD/oz)
  final double stopLossUsd;       // Vùng phòng hộ rủi ro SL (USD/oz)
  final double navAllocationPct;  // Tỷ trọng phân bổ vốn đề xuất (% NAV)
  final String headline;          // Tiêu đề khuyến nghị tóm tắt
  final String macroReasoning;     // Lập luận vĩ mô chi tiết (TIPS, DXY, NHTW, Địa chính trị)
  final String domesticAdvice;    // Lời khuyên cụ thể cho thị trường vàng Việt Nam (SJC & Nhẫn)
  final DateTime generatedAt;
  final bool isHeuristicFallback; // Cờ đánh dấu nếu chạy qua thuật toán nội bộ khi offline

  const GeminiAdvisorySignal({
    required this.signal,
    required this.confidenceScore,
    required this.targetPriceUsd,
    required this.stopLossUsd,
    required this.navAllocationPct,
    required this.headline,
    required this.macroReasoning,
    required this.domesticAdvice,
    required this.generatedAt,
    this.isHeuristicFallback = false,
  });

  /// Nhãn hiển thị tiếng Việt của tín hiệu
  String get signalLabel {
    switch (signal) {
      case ActionSignal.strongBuy:
        return 'MUA TÍCH LŨY MẠNH';
      case ActionSignal.moderateBuy:
        return 'MUA TÍCH SẢN ĐỊNH KỲ';
      case ActionSignal.hold:
        return 'NẮM GIỮ (HOLD)';
      case ActionSignal.trim:
        return 'HẠ TỶ TRỌNG';
      case ActionSignal.sell:
        return 'CHỐT LỜI / BÁN';
    }
  }

  /// Màu sắc đặc trưng của tín hiệu
  Color get signalColor {
    switch (signal) {
      case ActionSignal.strongBuy:
        return AurumColors.emerald;
      case ActionSignal.moderateBuy:
        return AurumColors.gold;
      case ActionSignal.hold:
        return AurumColors.sapphire;
      case ActionSignal.trim:
        return AurumColors.amber;
      case ActionSignal.sell:
        return AurumColors.ruby;
    }
  }

  /// Đạt ngưỡng cảnh báo ưu tiên cao (>= 85% độ tin cậy)
  bool get isHighPriorityAlert => confidenceScore >= 85;
}
