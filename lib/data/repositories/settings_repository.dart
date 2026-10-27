import '../../domain/models/app_settings_model.dart';
import '../services/local_storage_service.dart';

/// Kho quản lý cấu hình người dùng & tùy biến dữ liệu
class SettingsRepository {
  final LocalStorageService _storage;
  late AppSettingsModel _settings;

  SettingsRepository(this._storage) {
    _settings = _storage.loadSettings();
  }

  AppSettingsModel get settings => _settings;

  /// Lưu thiết lập mới
  Future<void> updateSettings(AppSettingsModel newSettings) async {
    _settings = newSettings;
    await _storage.saveSettings(_settings);
  }

  /// Cập nhật riêng API Keys
  Future<void> updateApiKeys({
    required String geminiKey,
    required String fredKey,
    required String feedKey,
  }) async {
    _settings = _settings.copyWith(
      geminiApiKey: geminiKey,
      fredApiKey: fredKey,
      goldFeedApiKey: feedKey,
    );
    await _storage.saveSettings(_settings);
  }

  /// Cập nhật dữ liệu giá vàng lịch sử từ CSV
  Future<void> saveCustomHistoricalPrices(Map<int, double> prices) async {
    await _storage.saveHistoricalPrices(prices);
  }

  /// Đọc dữ liệu giá vàng lịch sử hiện hành
  Map<int, double> getHistoricalPrices() {
    return _storage.loadHistoricalPrices();
  }
}
