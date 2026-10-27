import '../../domain/models/gold_vault_item.dart';
import '../services/local_storage_service.dart';

/// Kho quản lý tài sản Két Vàng cá nhân (Vault Repository)
class VaultRepository {
  final LocalStorageService _storage;
  List<GoldVaultItem> _items = [];

  VaultRepository(this._storage) {
    _items = _storage.loadVaultItems();
  }

  List<GoldVaultItem> get items => List.unmodifiable(_items);

  /// Thêm giao dịch vàng mới vào két
  Future<void> addItem(GoldVaultItem item) async {
    _items.insert(0, item);
    await _storage.saveVaultItems(_items);
  }

  /// Cập nhật thông tin giao dịch vàng
  Future<void> updateItem(GoldVaultItem item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index] = item;
      await _storage.saveVaultItems(_items);
    }
  }

  /// Xóa món vàng khỏi két
  Future<void> deleteItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _storage.saveVaultItems(_items);
  }

  /// Tính toán tổng quan tài sản trong két
  VaultSummary getSummary({
    required double currentRingPricePerChi,
    required double currentSjcPricePerLuong,
  }) {
    double totalChi = 0.0;
    double totalInvested = 0.0;
    double totalMarketValue = 0.0;

    for (final item in _items) {
      totalChi += item.totalChi;
      totalInvested += item.totalInvested;
      totalMarketValue += item.currentMarketValue(
        currentRingPricePerChi: currentRingPricePerChi,
        currentSjcPricePerLuong: currentSjcPricePerLuong,
      );
    }

    final double netProfit = totalMarketValue - totalInvested;
    final double roiPercent = totalInvested > 0 ? (netProfit / totalInvested) * 100.0 : 0.0;

    return VaultSummary(
      totalChi: totalChi,
      totalInvested: totalInvested,
      currentMarketValue: totalMarketValue,
      netProfit: netProfit,
      roiPercent: roiPercent,
      totalItems: _items.length,
    );
  }
}
