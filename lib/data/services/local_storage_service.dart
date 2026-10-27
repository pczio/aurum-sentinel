import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/historical_data_constants.dart';
import '../../domain/models/app_settings_model.dart';
import '../../domain/models/gold_vault_item.dart';

/// Dịch vụ lưu trữ cục bộ bảo mật trên thiết bị (Zero-Cloud Privacy)
class LocalStorageService {
  static const String _keySettings = 'aurum_settings_v1';
  static const String _keyVault = 'aurum_vault_items_v1';
  static const String _keyCustomHistory = 'aurum_custom_history_v1';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // ---- Cài đặt ứng dụng ----
  AppSettingsModel loadSettings() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null || raw.isEmpty) {
      return AppSettingsModel.defaultSettings();
    }
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      return AppSettingsModel.fromJson(jsonMap);
    } catch (_) {
      return AppSettingsModel.defaultSettings();
    }
  }

  Future<bool> saveSettings(AppSettingsModel settings) async {
    final raw = jsonEncode(settings.toJson());
    return _prefs.setString(_keySettings, raw);
  }

  // ---- Sổ tay Két Vàng (Vault Items) ----
  List<GoldVaultItem> loadVaultItems() {
    final raw = _prefs.getString(_keyVault);
    if (raw == null || raw.isEmpty) {
      return _generateDefaultVaultSeed();
    }
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => GoldVaultItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _generateDefaultVaultSeed();
    }
  }

  Future<bool> saveVaultItems(List<GoldVaultItem> items) async {
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    return _prefs.setString(_keyVault, raw);
  }

  // ---- Dữ liệu giá lịch sử nhập từ CSV ----
  Map<int, double> loadHistoricalPrices() {
    final raw = _prefs.getString(_keyCustomHistory);
    if (raw == null || raw.isEmpty) {
      return Map<int, double>.from(HistoricalDataConstants.defaultHistoricalPrices);
    }
    try {
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      final result = <int, double>{};
      map.forEach((k, v) {
        final year = int.tryParse(k);
        final price = (v as num).toDouble();
        if (year != null) result[year] = price;
      });
      return result.isNotEmpty ? result : Map<int, double>.from(HistoricalDataConstants.defaultHistoricalPrices);
    } catch (_) {
      return Map<int, double>.from(HistoricalDataConstants.defaultHistoricalPrices);
    }
  }

  Future<bool> saveHistoricalPrices(Map<int, double> prices) async {
    final map = prices.map((k, v) => MapEntry(k.toString(), v));
    return _prefs.setString(_keyCustomHistory, jsonEncode(map));
  }

  /// Khởi tạo dữ liệu mẫu ban đầu cho két vàng
  List<GoldVaultItem> _generateDefaultVaultSeed() {
    return [
      GoldVaultItem(
        id: 'seed-1',
        title: 'Nhẫn 999.9 PNJ Tích Lũy Đợt 1',
        brand: GoldBrandType.pnj,
        productType: GoldProductType.ring9999,
        unit: WeightUnit.chi,
        quantity: 2.0,
        buyPricePerUnit: 14200000.0,
        purchaseDate: DateTime(2026, 3, 10),
        storageNote: 'Két sắt gia đình',
      ),
      GoldVaultItem(
        id: 'seed-2',
        title: 'Vàng miếng SJC 1 lượng',
        brand: GoldBrandType.sjc,
        productType: GoldProductType.barSjc,
        unit: WeightUnit.luong,
        quantity: 1.0,
        buyPricePerUnit: 144500000.0,
        purchaseDate: DateTime(2026, 5, 20),
        storageNote: 'Tủ an toàn ngân hàng',
      ),
      GoldVaultItem(
        id: 'seed-3',
        title: 'Nhẫn tròn trơn DOJI Lương Tháng 7',
        brand: GoldBrandType.doji,
        productType: GoldProductType.ring9999,
        unit: WeightUnit.chi,
        quantity: 1.0,
        buyPricePerUnit: 14650000.0,
        purchaseDate: DateTime(2026, 7, 5),
        storageNote: 'Két cá nhân',
      ),
    ];
  }
}
