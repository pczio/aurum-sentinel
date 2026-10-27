import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/aurum_theme.dart';
import 'data/repositories/gold_market_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/vault_repository.dart';
import 'data/services/android_notification_service.dart';
import 'data/services/fred_api_service.dart';
import 'data/services/gemini_advisor_service.dart';
import 'data/services/gold_feed_service.dart';
import 'data/services/local_storage_service.dart';
import 'presentation/controllers/accumulation_controller.dart';
import 'presentation/controllers/gemini_advisor_controller.dart';
import 'presentation/controllers/gold_vault_controller.dart';
import 'presentation/controllers/market_intelligence_controller.dart';
import 'presentation/controllers/scenario_controller.dart';
import 'presentation/controllers/settings_controller.dart';
import 'presentation/screens/main_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khóa hướng màn hình dọc chuẩn cho ứng dụng điện thoại tài chính
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Cấu hình thanh trạng thái hệ thống Android trong suốt
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F131C),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 1. Khởi tạo tầng dịch vụ lưu trữ cục bộ & thông báo đẩy
  final storageService = await LocalStorageService.init();
  await AndroidNotificationService.instance.initialize();

  final feedService = GoldFeedService();
  final fredService = FredApiService();
  final geminiService = GeminiAdvisorService();

  // 2. Khởi tạo các kho dữ liệu (Repositories)
  final marketRepository = GoldMarketRepository(
    feedService: feedService,
    fredService: fredService,
    geminiService: geminiService,
    storageService: storageService,
  );

  final vaultRepository = VaultRepository(storageService);
  final settingsRepository = SettingsRepository(storageService);

  // 3. Khởi tạo các bộ điều khiển trạng thái (Controllers)
  final marketController = MarketIntelligenceController(marketRepository);
  final accumulationController = AccumulationController(marketRepository);
  final scenarioController = ScenarioController();
  final geminiController = GeminiAdvisorController(marketRepository);
  final vaultController = GoldVaultController(
    vaultRepository: vaultRepository,
    marketRepository: marketRepository,
  );

  final settingsController = SettingsController(
    settingsRepository,
    onHistoricalPricesReloaded: () {
      accumulationController.runSimulation();
    },
  );

  runApp(
    AurumSentinelApp(
      marketController: marketController,
      accumulationController: accumulationController,
      scenarioController: scenarioController,
      geminiController: geminiController,
      vaultController: vaultController,
      settingsController: settingsController,
    ),
  );
}

/// Ứng dụng Android AurumSentinel: Gold Wealth & Autonomous Market Intelligence
class AurumSentinelApp extends StatelessWidget {
  final MarketIntelligenceController marketController;
  final AccumulationController accumulationController;
  final ScenarioController scenarioController;
  final GeminiAdvisorController geminiController;
  final GoldVaultController vaultController;
  final SettingsController settingsController;

  const AurumSentinelApp({
    super.key,
    required this.marketController,
    required this.accumulationController,
    required this.scenarioController,
    required this.geminiController,
    required this.vaultController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AurumSentinel · Gold Wealth MVP',
      debugShowCheckedModeBanner: false,
      theme: AurumTheme.darkTheme,
      home: MainShellScreen(
        marketController: marketController,
        accumulationController: accumulationController,
        scenarioController: scenarioController,
        geminiController: geminiController,
        vaultController: vaultController,
        settingsController: settingsController,
      ),
    );
  }
}
