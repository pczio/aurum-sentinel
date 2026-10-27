import 'package:flutter/material.dart';
import '../../core/constants/historical_data_constants.dart';
import '../../core/constants/market_constants.dart';
import '../../domain/engines/accumulation_engine.dart';
import '../../domain/engines/monte_carlo_engine.dart';
import '../../domain/models/gold_scenario.dart';

/// Bộ điều khiển phân hệ Kịch Bản Dự Báo 2026 & Phân Tích Monte Carlo
class ScenarioController extends ChangeNotifier {
  double _monthlyIncome = MarketConstants.defaultMonthlyIncome;
  int _selectedLevelPct = 20; // 20% tích lũy
  int _forecastYears = 10;
  double _currentPrice = MarketConstants.defaultCurrentRingPrice;

  List<GoldScenario> _scenarios = [];
  Map<String, ScenarioSimulationResult> _simulationResults = {};
  MonteCarloSimulationResult? _monteCarloResult;
  bool _isRunningMonteCarlo = false;

  ScenarioController() {
    _initScenarios();
    runScenarioSimulation();
    runMonteCarlo();
  }

  double get monthlyIncome => _monthlyIncome;
  int get selectedLevelPct => _selectedLevelPct;
  int get forecastYears => _forecastYears;
  double get currentPrice => _currentPrice;
  List<GoldScenario> get scenarios => List.unmodifiable(_scenarios);
  Map<String, ScenarioSimulationResult> get simulationResults => _simulationResults;
  MonteCarloSimulationResult? get monteCarloResult => _monteCarloResult;
  bool get isRunningMonteCarlo => _isRunningMonteCarlo;

  void _initScenarios() {
    _scenarios = HistoricalDataConstants.defaultScenarios.values.map((map) {
      return GoldScenario(
        id: map['id'] as String,
        label: map['label'] as String,
        cagrPct: (map['cagr'] as num).toDouble(),
        color: Color(map['colorValue'] as int),
        note: map['note'] as String,
      );
    }).toList();
  }

  void updateInputs({
    double? monthlyIncome,
    int? selectedLevelPct,
    int? forecastYears,
    double? currentPrice,
  }) {
    if (monthlyIncome != null) _monthlyIncome = monthlyIncome;
    if (selectedLevelPct != null) _selectedLevelPct = selectedLevelPct;
    if (forecastYears != null) _forecastYears = forecastYears;
    if (currentPrice != null) _currentPrice = currentPrice;
    runScenarioSimulation();
    runMonteCarlo();
  }

  void updateScenarioCagr(String scenarioId, double newCagr) {
    final index = _scenarios.indexWhere((s) => s.id == scenarioId);
    if (index != -1) {
      _scenarios[index] = _scenarios[index].copyWith(cagrPct: newCagr);
      runScenarioSimulation();
    }
  }

  /// Chạy mô phỏng 3 kịch bản
  void runScenarioSimulation() {
    final engine = AccumulationEngine(
      monthlyIncome: _monthlyIncome,
      levelsPct: [_selectedLevelPct],
    );

    _simulationResults = engine.simulateFutureScenarios(
      currentPrice: _currentPrice,
      years: _forecastYears,
      levelPct: _selectedLevelPct,
      scenarios: _scenarios,
    );

    notifyListeners();
  }

  /// Chạy mô phỏng ngẫu nhiên 1.000 chu kỳ Monte Carlo
  Future<void> runMonteCarlo() async {
    _isRunningMonteCarlo = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 150));

    _monteCarloResult = MonteCarloEngine.runSimulation(
      monthlyIncome: _monthlyIncome,
      levelPct: _selectedLevelPct,
      startPrice: _currentPrice,
      years: _forecastYears,
      expectedAnnualReturn: 0.10,
      annualVolatility: 0.16,
      numRuns: 1000,
    );

    _isRunningMonteCarlo = false;
    notifyListeners();
  }
}
