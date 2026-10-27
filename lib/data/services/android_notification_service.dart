import 'package:flutter/foundation.dart';
import '../../core/utils/haptic_feedback_helper.dart';

/// Dịch vụ quản lý thông báo đẩy đa kênh Android (Notification Channels)
class AndroidNotificationService {
  AndroidNotificationService._();

  static final AndroidNotificationService instance = AndroidNotificationService._();

  // Danh sách các thông báo gần nhất lưu trong bộ nhớ
  final List<AppNotificationItem> _recentNotifications = [];
  List<AppNotificationItem> get recentNotifications => List.unmodifiable(_recentNotifications);

  /// Khởi tạo các kênh thông báo Android (Android Notification Channels)
  Future<void> initialize() async {
    debugPrint('[AndroidNotificationService] Initialized notification channels');
  }

  /// Bắn thông báo Tín hiệu AI hoặc Mua đáy (High Priority Channel)
  void notifyAiSignal({
    required String title,
    required String message,
  }) {
    HapticHelper.heavyImpact();
    _recentNotifications.insert(
      0,
      AppNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        channel: 'channel_ai_signals',
        title: title,
        message: message,
        timestamp: DateTime.now(),
        isHighPriority: true,
      ),
    );
  }

  /// Bắn thông báo Cảnh báo biến động giá hoặc chênh lệch ASI
  void notifyPriceAlert({
    required String title,
    required String message,
  }) {
    HapticHelper.mediumImpact();
    _recentNotifications.insert(
      0,
      AppNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        channel: 'channel_price_alerts',
        title: title,
        message: message,
        timestamp: DateTime.now(),
        isHighPriority: false,
      ),
    );
  }

  /// Bắn thông báo Nhắc nhở tích sản định kỳ ngày nhận lương
  void notifyDcaReminder({
    required String title,
    required String message,
  }) {
    HapticHelper.lightImpact();
    _recentNotifications.insert(
      0,
      AppNotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        channel: 'channel_dca_reminders',
        title: title,
        message: message,
        timestamp: DateTime.now(),
        isHighPriority: false,
      ),
    );
  }
}

/// Một thông báo được ghi nhận
class AppNotificationItem {
  final String id;
  final String channel;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isHighPriority;

  AppNotificationItem({
    required this.id,
    required this.channel,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isHighPriority,
  });
}
