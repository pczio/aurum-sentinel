import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aurumsentinel_app/data/repositories/gold_market_repository.dart';
import 'package:aurumsentinel_app/data/repositories/settings_repository.dart';
import 'package:aurumsentinel_app/data/repositories/vault_repository.dart';
import 'package:aurumsentinel_app/data/services/fred_api_service.dart';
import 'package:aurumsentinel_app/data/services/gemini_advisor_service.dart';
import 'package:aurumsentinel_app/data/services/gold_feed_service.dart';
import 'package:aurumsentinel_app/data/services/local_storage_service.dart';
import 'package:aurumsentinel_app/main.dart';
import 'package:aurumsentinel_app/presentation/controllers/accumulation_controller.dart';
import 'package:aurumsentinel_app/presentation/controllers/gemini_advisor_controller.dart';
import 'package:aurumsentinel_app/presentation/controllers/gold_vault_controller.dart';
import 'package:aurumsentinel_app/presentation/controllers/market_intelligence_controller.dart';
import 'package:aurumsentinel_app/presentation/controllers/scenario_controller.dart';
import 'package:aurumsentinel_app/presentation/controllers/settings_controller.dart';

void main() {
  testWidgets('AurumSentinelApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.init();

    final feedService = GoldFeedService();
    final fredService = FredApiService();
    final geminiService = GeminiAdvisorService();

    final marketRepository = GoldMarketRepository(
      feedService: feedService,
      fredService: fredService,
      geminiService: geminiService,
      storageService: storage,
    );

    final vaultRepository = VaultRepository(storage);
    final settingsRepository = SettingsRepository(storage);

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
      onHistoricalPricesReloaded: () {},
    );

    await tester.pumpWidget(
      AurumSentinelApp(
        marketController: marketController,
        accumulationController: accumulationController,
        scenarioController: scenarioController,
        geminiController: geminiController,
        vaultController: vaultController,
        settingsController: settingsController,
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify main screen renders without errors
    expect(find.text('Tích Sản Lãi Kép Vàng'), findsOneWidget);
  });
}
