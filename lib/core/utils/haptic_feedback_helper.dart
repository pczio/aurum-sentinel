import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Hỗ trợ phản hồi xúc giác (Haptic Feedback) trên Android
class HapticHelper {
  HapticHelper._();

  /// Rung nhẹ khi chạm nút hoặc tương tác thẻ
  static void lightImpact() {
    if (kIsWeb) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Rung vừa khi chuyển tab hoặc lưu dữ liệu
  static void mediumImpact() {
    if (kIsWeb) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Rung mạnh khi có cảnh báo tín hiệu mua đáy / rủi ro chênh lệch
  static void heavyImpact() {
    if (kIsWeb) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Rung kiểu chọn lựa (tick) khi kéo thanh trượt Slider
  static void selectionClick() {
    if (kIsWeb) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
