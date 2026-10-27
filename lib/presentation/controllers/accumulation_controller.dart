import 'package:flutter/material.dart';
import '../../data/repositories/gold_market_repository.dart';
import '../../data/services/csv_export_import_service.dart';
import '../../domain/engines/accumulation_engine.dart';
import '../../domain/models/accumulation_models.dart';

enum AccumulationViewMode {
  historical, // Lịch sử (2006 -> Hiện tại)
  future,     // Dự phóng tương lai (Lãi kép)
  comparison, // Bảng so sánh đa cấp độ
}

/// Bộ điều khiển phân hệ Tích Sản Lãi Kép Vàng
class AccumulationController extends ChangeNotifier {
  final GoldMarketRepository _repository;

  late AccumulationConfig _config;
  late AccumulationViewMode _viewMode;
  int _selectedLevel = 20; // Mặc định 20% như trong tài liệu gia-vang.md

  List<SimulationResult> _historicalResults = [];
  List<SimulationResult> _futureResults = [];

  AccumulationController(this._repository) {
    _config = AccumulationConfig.defaultConfig();
    _viewMode = AccumulationViewMode.historical;
    runSimulation();
  }

  AccumulationConfig get config => _config;
  AccumulationViewMode get viewMode => _viewMode;
  int get selectedLevel => _selectedLevel;
  List<SimulationResult> get historicalResults => _historicalResults;
  List<SimulationResult> get futureResults => _futureResults;

  void setViewMode(AccumulationViewMode mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      notifyListeners();
    }
  }

  void setSelectedLevel(int level) {
    if (_selectedLevel != level) {
      _selectedLevel = level;
      notifyListeners();
    }
  }

  /// Cập nhật đầu vào tính toán (Thu nhập, các mức %, số năm, CAGR)
  void updateConfig({
    double? monthlyIncome,
    List<int>? levelsPct,
    int? historyStartYear,
    int? futureYears,
    double? futureCagrPct,
    double? currentPricePerChi,
  }) {
    _config = _config.copyWith(
      monthlyIncome: monthlyIncome,
      levelsPct: levelsPct,
      historyStartYear: historyStartYear,
      futureYears: futureYears,
      futureCagrPct: futureCagrPct,
      currentPricePerChi: currentPricePerChi,
    );
    runSimulation();
  }

  /// Chạy lại cỗ máy mô phỏng tích sản lãi kép
  void runSimulation() {
    final curve = _repository.getGoldPriceCurve();
    final engine = AccumulationEngine(
      monthlyIncome: _config.monthlyIncome,
      levelsPct: _config.levelsPct,
    );

    final int currentYear = DateTime.now().year;
    final int currentMonth = DateTime.now().month;

    // 1. Mô phỏng lịch sử
    _historicalResults = engine.simulateHistorical(
      curve: curve,
      startYear: _config.historyStartYear,
      endYear: currentYear,
      endMonth: currentMonth,
    );

    // 2. Mô phỏng dự phóng tương lai lãi kép
    _futureResults = engine.simulateFuture(
      currentPrice: _config.currentPricePerChi,
      years: _config.futureYears,
      annualCagrPct: _config.futureCagrPct,
    );

    notifyListeners();
  }

  /// Xuất kết quả toàn bộ chuỗi số liệu ra nội dung tệp CSV
  String exportToCsv() {
    return CsvExportImportService.exportSimulationToCsv(
      historicalResults: _historicalResults,
      futureResults: _futureResults,
    );
  }
}
