import 'package:flutter/foundation.dart';
import '../../core/constants/market_constants.dart';

/// Thiết lập người dùng & cấu hình ứng dụng AurumSentinel
@immutable
class AppSettingsModel {
  final double monthlyIncome;
  final double currentPricePerChi;
  final List<int> accumulationLevels;
  final int historyStartYear;
  final int futureYears;
  final double futureCagrPct;
  final String geminiApiKey;
  final String fredApiKey;
  final String goldFeedApiKey;
  final bool enableNotifications;
  final bool enableDipAlerts;
  final bool enableDcaReminder;
  final int dcaReminderDayOfMonth;
  final double customSjcAlertPrice;
  final double customAsiAlertThreshold;

  const AppSettingsModel({
    required this.monthlyIncome,
    required this.currentPricePerChi,
    required this.accumulationLevels,
    required this.historyStartYear,
    required this.futureYears,
    required this.futureCagrPct,
    required this.geminiApiKey,
    required this.fredApiKey,
    required this.goldFeedApiKey,
    required this.enableNotifications,
    required this.enableDipAlerts,
    required this.enableDcaReminder,
    required this.dcaReminderDayOfMonth,
    required this.customSjcAlertPrice,
    required this.customAsiAlertThreshold,
  });

  AppSettingsModel copyWith({
    double? monthlyIncome,
    double? currentPricePerChi,
    List<int>? accumulationLevels,
    int? historyStartYear,
    int? futureYears,
    double? futureCagrPct,
    String? geminiApiKey,
    String? fredApiKey,
    String? goldFeedApiKey,
    bool? enableNotifications,
    bool? enableDipAlerts,
    bool? enableDcaReminder,
    int? dcaReminderDayOfMonth,
    double? customSjcAlertPrice,
    double? customAsiAlertThreshold,
  }) {
    return AppSettingsModel(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      currentPricePerChi: currentPricePerChi ?? this.currentPricePerChi,
      accumulationLevels: accumulationLevels ?? this.accumulationLevels,
      historyStartYear: historyStartYear ?? this.historyStartYear,
      futureYears: futureYears ?? this.futureYears,
      futureCagrPct: futureCagrPct ?? this.futureCagrPct,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      fredApiKey: fredApiKey ?? this.fredApiKey,
      goldFeedApiKey: goldFeedApiKey ?? this.goldFeedApiKey,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableDipAlerts: enableDipAlerts ?? this.enableDipAlerts,
      enableDcaReminder: enableDcaReminder ?? this.enableDcaReminder,
      dcaReminderDayOfMonth: dcaReminderDayOfMonth ?? this.dcaReminderDayOfMonth,
      customSjcAlertPrice: customSjcAlertPrice ?? this.customSjcAlertPrice,
      customAsiAlertThreshold: customAsiAlertThreshold ?? this.customAsiAlertThreshold,
    );
  }

  factory AppSettingsModel.defaultSettings() {
    return const AppSettingsModel(
      monthlyIncome: MarketConstants.defaultMonthlyIncome,
      currentPricePerChi: MarketConstants.defaultCurrentRingPrice,
      accumulationLevels: MarketConstants.defaultAccumulationLevels,
      historyStartYear: MarketConstants.defaultStartYear,
      futureYears: MarketConstants.defaultFutureYears,
      futureCagrPct: MarketConstants.defaultFutureCagr,
      geminiApiKey: '',
      fredApiKey: '',
      goldFeedApiKey: '',
      enableNotifications: true,
      enableDipAlerts: true,
      enableDcaReminder: true,
      dcaReminderDayOfMonth: 5,
      customSjcAlertPrice: 145000000.0,
      customAsiAlertThreshold: MarketConstants.asiSafeThreshold,
    );
  }

  Map<String, dynamic> toJson() => {
        'monthlyIncome': monthlyIncome,
        'currentPricePerChi': currentPricePerChi,
        'accumulationLevels': accumulationLevels,
        'historyStartYear': historyStartYear,
        'futureYears': futureYears,
        'futureCagrPct': futureCagrPct,
        'geminiApiKey': geminiApiKey,
        'fredApiKey': fredApiKey,
        'goldFeedApiKey': goldFeedApiKey,
        'enableNotifications': enableNotifications,
        'enableDipAlerts': enableDipAlerts,
        'enableDcaReminder': enableDcaReminder,
        'dcaReminderDayOfMonth': dcaReminderDayOfMonth,
        'customSjcAlertPrice': customSjcAlertPrice,
        'customAsiAlertThreshold': customAsiAlertThreshold,
      };

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) => AppSettingsModel(
        monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? MarketConstants.defaultMonthlyIncome,
        currentPricePerChi: (json['currentPricePerChi'] as num?)?.toDouble() ?? MarketConstants.defaultCurrentRingPrice,
        accumulationLevels: (json['accumulationLevels'] as List<dynamic>?)?.map((e) => e as int).toList() ??
            MarketConstants.defaultAccumulationLevels,
        historyStartYear: json['historyStartYear'] as int? ?? MarketConstants.defaultStartYear,
        futureYears: json['futureYears'] as int? ?? MarketConstants.defaultFutureYears,
        futureCagrPct: (json['futureCagrPct'] as num?)?.toDouble() ?? MarketConstants.defaultFutureCagr,
        geminiApiKey: json['geminiApiKey'] as String? ?? '',
        fredApiKey: json['fredApiKey'] as String? ?? '',
        goldFeedApiKey: json['goldFeedApiKey'] as String? ?? '',
        enableNotifications: json['enableNotifications'] as bool? ?? true,
        enableDipAlerts: json['enableDipAlerts'] as bool? ?? true,
        enableDcaReminder: json['enableDcaReminder'] as bool? ?? true,
        dcaReminderDayOfMonth: json['dcaReminderDayOfMonth'] as int? ?? 5,
        customSjcAlertPrice: (json['customSjcAlertPrice'] as num?)?.toDouble() ?? 145000000.0,
        customAsiAlertThreshold:
            (json['customAsiAlertThreshold'] as num?)?.toDouble() ?? MarketConstants.asiSafeThreshold,
      );
}
