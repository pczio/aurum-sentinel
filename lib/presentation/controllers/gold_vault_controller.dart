import 'package:flutter/material.dart';
import '../../data/repositories/gold_market_repository.dart';
import '../../data/repositories/vault_repository.dart';
import '../../domain/engines/multi_asset_engine.dart';
import '../../domain/models/gold_vault_item.dart';
import '../../domain/models/multi_asset_models.dart';

enum VaultSubTab {
  safeItems,   // Danh sách tài sản trong két
  rule8020,    // Rổ phân bổ 80-20
  comparison,  // So sánh Vàng vs Tiết kiệm vs Quỹ trái phiếu
}

/// Bộ điều khiển phân hệ Két Vàng Cá Nhân & Phân Bổ Danh Mục
class GoldVaultController extends ChangeNotifier {
  final VaultRepository _vaultRepository;
  final GoldMarketRepository _marketRepository;

  VaultSubTab _subTab = VaultSubTab.safeItems;
  late Portfolio8020Allocation _allocation8020;
  late MultiAssetComparisonResult _multiAssetComparison;

  GoldVaultController({
    required VaultRepository vaultRepository,
    required GoldMarketRepository marketRepository,
  })  : _vaultRepository = vaultRepository,
        _marketRepository = marketRepository {
    _allocation8020 = MultiAssetEngine.calculate8020(monthlyIncome: 15000000.0);
    _multiAssetComparison = MultiAssetEngine.compareVehicles(
      monthlyDeposit: 3000000.0, // 20% của 15 triệu
      years: 10,
    );
  }

  VaultSubTab get subTab => _subTab;
  List<GoldVaultItem> get items => _vaultRepository.items;
  Portfolio8020Allocation get allocation8020 => _allocation8020;
  MultiAssetComparisonResult get multiAssetComparison => _multiAssetComparison;

  void setSubTab(VaultSubTab tab) {
    if (_subTab != tab) {
      _subTab = tab;
      notifyListeners();
    }
  }

  /// Tính tổng quan két vàng dựa trên giá thị trường hiện thời
  VaultSummary getSummary() {
    final snap = _marketRepository.currentSnapshot;
    return _vaultRepository.getSummary(
      currentRingPricePerChi: snap.ringSellPerChi,
      currentSjcPricePerLuong: snap.sjcSellPerLuong,
    );
  }

  /// Thêm món vàng mới
  Future<void> addItem(GoldVaultItem item) async {
    await _vaultRepository.addItem(item);
    notifyListeners();
  }

  /// Cập nhật món vàng
  Future<void> updateItem(GoldVaultItem item) async {
    await _vaultRepository.updateItem(item);
    notifyListeners();
  }

  /// Xóa món vàng
  Future<void> deleteItem(String id) async {
    await _vaultRepository.deleteItem(id);
    notifyListeners();
  }

  /// Cập nhật thông số rổ phân bổ 80-20
  void update8020({
    required double monthlyIncome,
    double savingsPercent = 20.0,
    double goldInSavingsPercent = 20.0,
    double emergencyMonths = 6.0,
  }) {
    _allocation8020 = MultiAssetEngine.calculate8020(
      monthlyIncome: monthlyIncome,
      savingsPercent: savingsPercent,
      goldInSavingsPercent: goldInSavingsPercent,
      emergencyMonths: emergencyMonths,
    );
    notifyListeners();
  }

  /// Cập nhật thông số so sánh đa kênh
  void updateMultiAssetComparison({
    required double monthlyDeposit,
    required int years,
    double goldCagr = 10.5,
    double bankInterestRate = 5.5,
    double bondYield = 7.8,
  }) {
    _multiAssetComparison = MultiAssetEngine.compareVehicles(
      monthlyDeposit: monthlyDeposit,
      years: years,
      goldAnnualCagr: goldCagr,
      bankInterestRate: bankInterestRate,
      bondYield: bondYield,
    );
    notifyListeners();
  }
}
