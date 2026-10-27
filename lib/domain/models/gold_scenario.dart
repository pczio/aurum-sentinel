import 'package:flutter/material.dart';
import 'accumulation_models.dart';

/// Định nghĩa kịch bản dự phóng giá vàng tương lai
@immutable
class GoldScenario {
  final String id;
  final String label;
  final double cagrPct;            // Tăng trưởng kép hàng năm %
  final Color color;
  final String note;

  const GoldScenario({
    required this.id,
    required this.label,
    required this.cagrPct,
    required this.color,
    required this.note,
  });

  GoldScenario copyWith({
    String? id,
    String? label,
    double? cagrPct,
    Color? color,
    String? note,
  }) {
    return GoldScenario(
      id: id ?? this.id,
      label: label ?? this.label,
      cagrPct: cagrPct ?? this.cagrPct,
      color: color ?? this.color,
      note: note ?? this.note,
    );
  }
}

/// Kết hợp kết quả mô phỏng với thông tin kịch bản
@immutable
class ScenarioSimulationResult {
  final GoldScenario scenario;
  final SimulationResult simulation;

  const ScenarioSimulationResult({
    required this.scenario,
    required this.simulation,
  });

  double get finalValue => simulation.totalValue;
  double get finalChi => simulation.totalChi;
  double get totalInvested => simulation.totalInvested;
  double get gainPct => simulation.gainPct;
  double get profit => simulation.totalProfit;
}
