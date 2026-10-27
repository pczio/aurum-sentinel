import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../controllers/gemini_advisor_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../../data/services/android_notification_service.dart';
import '../../widgets/cards/dip_alert_card.dart';
import '../../widgets/cards/gemini_signal_card.dart';

/// Tab 4: Cố Vấn Tài Chính Gemini AI & Radar Săn Đáy (Dip-Buying)
class GeminiAdvisorTab extends StatelessWidget {
  final GeminiAdvisorController controller;
  final SettingsController settingsController;

  const GeminiAdvisorTab({
    super.key,
    required this.controller,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final signal = controller.currentSignal;
        final dip = controller.currentDip;
        final notifications = AndroidNotificationService.instance.recentNotifications;
        final hasKey = settingsController.settings.geminiApiKey.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông báo trạng thái kết nối Gemini API
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasKey ? AurumColors.emerald.withOpacity(0.12) : AurumColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasKey ? AurumColors.emerald.withOpacity(0.4) : AurumColors.borderGold,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasKey ? Icons.check_circle_outline : Icons.info_outline,
                      size: 16,
                      color: hasKey ? AurumColors.emerald : AurumColors.goldBright,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasKey
                            ? 'Đã kết nối Google Gemini API trực tuyến'
                            : 'Đang chạy Heuristic AI Engine định lượng nội bộ (Offline)',
                        style: TextStyle(
                          color: hasKey ? AurumColors.emerald : AurumColors.goldBright,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 1. Thẻ chiến lược Gemini AI Financial Advisor
              if (signal != null) ...[
                GeminiSignalCard(
                  signal: signal,
                  isLoading: controller.isLoadingAi,
                  onRefresh: () => controller.requestAdvisory(
                    geminiApiKey: settingsController.settings.geminiApiKey,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 2. Thẻ Radar Săn Đáy (Dip-Buying Radar)
              if (dip != null) ...[
                DipAlertCard(dipSignal: dip),
                const SizedBox(height: 14),
              ],

              // 3. Nút kích hoạt phân tích lại toàn diện
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoadingAi
                      ? null
                      : () => controller.requestAdvisory(
                            geminiApiKey: settingsController.settings.geminiApiKey,
                          ),
                  icon: controller.isLoadingAi
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF141002)),
                        )
                      : const Icon(Icons.auto_awesome, size: 18),
                  label: Text(
                    controller.isLoadingAi ? 'Đang Phân Tích 12 Biến Số...' : 'Quét Lại Thị Trường Bằng AI',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AurumColors.gold,
                    foregroundColor: const Color(0xFF141002),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Lịch sử cảnh báo & Thông báo đẩy Android gần nhất
              _buildNotificationHistory(notifications),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationHistory(List<AppNotificationItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AurumColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AurumColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active_outlined, color: AurumColors.sapphire, size: 18),
              SizedBox(width: 8),
              Text(
                'Nhật Ký Tín Hiệu & Cảnh Báo Android',
                style: TextStyle(color: AurumColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Chưa có tín hiệu mới phát sinh hôm nay.',
                  style: TextStyle(color: AurumColors.textMuted, fontSize: 11.5),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.take(4).length,
              separatorBuilder: (_, _) => const Divider(height: 14, color: AurumColors.borderSubtle),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: item.isHighPriority ? AurumColors.emerald : AurumColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: AurumColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.message,
                            style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormatter.formatDateTime(item.timestamp),
                            style: const TextStyle(color: AurumColors.textMuted, fontSize: 9.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
