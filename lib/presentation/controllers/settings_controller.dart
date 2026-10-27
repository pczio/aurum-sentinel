import 'package:flutter/material.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/csv_export_import_service.dart';
import '../../domain/models/app_settings_model.dart';

/// Bộ điều khiển phân hệ Cài Đặt, Khóa API & Nhập/Xuất Dữ Liệu
class SettingsController extends ChangeNotifier {
  final SettingsRepository _repository;
  final VoidCallback _onHistoricalPricesReloaded;

  late AppSettingsModel _settings;

  SettingsController(this._repository, {required VoidCallback onHistoricalPricesReloaded})
      : _onHistoricalPricesReloaded = onHistoricalPricesReloaded {
    _settings = _repository.settings;
  }

  AppSettingsModel get settings => _settings;

  /// Cập nhật thiết lập chung
  Future<void> updateSettings(AppSettingsModel newSettings) async {
    _settings = newSettings;
    await _repository.updateSettings(newSettings);
    notifyListeners();
  }

  /// Cập nhật riêng API Keys
  Future<void> saveApiKeys({
    required String geminiKey,
    required String fredKey,
    required String feedKey,
  }) async {
    _settings = _settings.copyWith(
      geminiApiKey: geminiKey.trim(),
      fredApiKey: fredKey.trim(),
      goldFeedApiKey: feedKey.trim(),
    );
    await _repository.updateSettings(_settings);
    notifyListeners();
  }

  /// Nhập bảng giá vàng lịch sử từ nội dung CSV
  Future<bool> importHistoricalCsv(String csvContent) async {
    final parsed = CsvExportImportService.parseHistoricalCsv(csvContent);
    if (parsed.isNotEmpty) {
      await _repository.saveCustomHistoricalPrices(parsed);
      _onHistoricalPricesReloaded();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Xuất bảng giá vàng lịch sử hiện hành
  String exportHistoricalPricesCsv() {
    final prices = _repository.getHistoricalPrices();
    return CsvExportImportService.exportHistoricalPricesToCsv(prices);
  }
}
