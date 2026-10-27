import 'package:flutter/material.dart';
import '../../core/constants/aurum_colors.dart';
import '../controllers/accumulation_controller.dart';
import '../controllers/gemini_advisor_controller.dart';
import '../controllers/gold_vault_controller.dart';
import '../controllers/market_intelligence_controller.dart';
import '../controllers/scenario_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/common/aurum_app_bar.dart';
import '../widgets/common/aurum_bottom_nav_bar.dart';
import '../widgets/common/floating_mini_hud.dart';
import 'settings/settings_screen.dart';
import 'tabs/accumulation_dca_tab.dart';
import 'tabs/gemini_advisor_tab.dart';
import 'tabs/gold_vault_tab.dart';
import 'tabs/market_intelligence_tab.dart';
import 'tabs/scenario_forecast_tab.dart';

/// Khung giao diện chính (Shell Screen) điều phối 5 phân hệ tính năng
class MainShellScreen extends StatefulWidget {
  final MarketIntelligenceController marketController;
  final AccumulationController accumulationController;
  final ScenarioController scenarioController;
  final GeminiAdvisorController geminiController;
  final GoldVaultController vaultController;
  final SettingsController settingsController;

  const MainShellScreen({
    super.key,
    required this.marketController,
    required this.accumulationController,
    required this.scenarioController,
    required this.geminiController,
    required this.vaultController,
    required this.settingsController,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  // Mặc định mở tab Tích Sản Lãi Kép (index 1) theo đúng quy chuẩn tài liệu
  int _currentIndex = 1;
  bool _showFloatingHud = true;

  final List<String> _tabTitles = [
    'Thị Trường & SJC Arbitrage',
    'Tích Sản Lãi Kép Vàng',
    'Kịch Bản Dự Báo 2026',
    'Cố Vấn Tài Chính Gemini AI',
    'Két Vàng & Rổ Phân Bổ 80-20',
  ];

  final List<String> _tabSubtitles = [
    'XAU/USD · Vàng Miếng SJC · Nhẫn 9999 · ASI',
    'Mô Phỏng DCA Lịch Sử & Tương Lai',
    'Phân Tích Đa Kịch Bản & Thử Tải Monte Carlo',
    'Phân Tích 12 Biến Số Vĩ Mô & Radar Săn Đáy',
    'Sổ Tay Tài Sản Cá Nhân & Phân Bổ Phòng Thủ',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AurumColors.bgRoot,
      appBar: AurumAppBar(
        title: _tabTitles[_currentIndex],
        subtitle: _tabSubtitles[_currentIndex],
        actions: [
          IconButton(
            icon: Icon(
              _showFloatingHud
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _showFloatingHud
                  ? AurumColors.gold
                  : AurumColors.textMuted,
              size: 20,
            ),
            tooltip: 'Bật/Tắt Thanh Mini-HUD',
            onPressed: () =>
                setState(() => _showFloatingHud = !_showFloatingHud),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AurumColors.textPrimary,
              size: 20,
            ),
            tooltip: 'Cài Đặt & Khóa API',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SettingsScreen(controller: widget.settingsController),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            color: AurumColors.bgPanel,
            child: const Text(
              'MVP · Giá vàng mô phỏng · Dữ liệu lưu trên trình duyệt',
              textAlign: TextAlign.center,
              style: TextStyle(color: AurumColors.textMuted, fontSize: 11),
            ),
          ),
          // Khung nổi Mini-HUD xem nhanh giá và tín hiệu
          if (_showFloatingHud)
            ListenableBuilder(
              listenable: Listenable.merge([
                widget.marketController,
                widget.geminiController,
              ]),
              builder: (context, _) {
                return FloatingMiniHudWidget(
                  snapshot: widget.marketController.snapshot,
                  arbitrage: widget.marketController.arbitrageResult,
                  signal: widget.geminiController.currentSignal,
                );
              },
            ),

          // 5 Màn hình Tab chính lưu trạng thái bằng IndexedStack
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                MarketIntelligenceTab(controller: widget.marketController),
                AccumulationDcaTab(controller: widget.accumulationController),
                ScenarioForecastTab(controller: widget.scenarioController),
                GeminiAdvisorTab(
                  controller: widget.geminiController,
                  settingsController: widget.settingsController,
                ),
                GoldVaultTab(
                  controller: widget.vaultController,
                  marketController: widget.marketController,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AurumBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
