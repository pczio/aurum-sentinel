import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../controllers/settings_controller.dart';
import '../../widgets/common/aurum_app_bar.dart';

/// Màn hình Cài Đặt, Quản Lý Khóa API & Nhập/Xuất Dữ Liệu CSV
class SettingsScreen extends StatefulWidget {
  final SettingsController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _geminiController;
  late TextEditingController _fredController;
  late TextEditingController _feedController;
  late TextEditingController _csvImportController;

  @override
  void initState() {
    super.initState();
    final s = widget.controller.settings;
    _geminiController = TextEditingController(text: s.geminiApiKey);
    _fredController = TextEditingController(text: s.fredApiKey);
    _feedController = TextEditingController(text: s.goldFeedApiKey);
    _csvImportController = TextEditingController();
  }

  @override
  void dispose() {
    _geminiController.dispose();
    _fredController.dispose();
    _feedController.dispose();
    _csvImportController.dispose();
    super.dispose();
  }

  void _saveKeys() {
    widget.controller.saveApiKeys(
      geminiKey: _geminiController.text,
      fredKey: _fredController.text,
      feedKey: _feedController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu API Keys cục bộ trên thiết bị (Zero-Cloud Privacy).'),
        backgroundColor: AurumColors.emerald,
      ),
    );
  }

  void _importCsv() async {
    final text = _csvImportController.text.trim();
    if (text.isEmpty) return;

    final success = await widget.controller.importHistoricalCsv(text);
    if (!mounted) return;

    if (success) {
      _csvImportController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã nạp thành công bảng giá lịch sử tùy biến từ CSV!'),
          backgroundColor: AurumColors.emerald,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi định dạng CSV. Vui lòng nhập mỗi dòng: năm,giá_vnd_mỗi_chỉ'),
          backgroundColor: AurumColors.ruby,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final settings = widget.controller.settings;

        return Scaffold(
          appBar: AurumAppBar(
            title: 'Cài Đặt & Cấu Hình',
            subtitle: 'Bảo Mật Cục Bộ · Zero-Cloud Storage',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Quản lý API Keys
                _buildSectionHeader('Khóa API Nguồn Dữ Liệu', Icons.key_outlined),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AurumColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AurumColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildKeyField(
                        label: 'Google Gemini API Key',
                        controller: _geminiController,
                        hint: 'AIzaSy...',
                        helper: 'Dùng để gọi mô hình Gemini 1.5/2.0 Flash phân tích vĩ mô 12 biến số.',
                      ),
                      const SizedBox(height: 14),
                      _buildKeyField(
                        label: 'FRED API Key (Cục Dự Trữ Liên Bang Mỹ)',
                        controller: _fredController,
                        hint: 'Nhập FRED key để tự động tải 10Y TIPS...',
                        helper: 'Truy xuất tự động Lợi suất thực 10 năm TIPS (DFII10).',
                      ),
                      const SizedBox(height: 14),
                      _buildKeyField(
                        label: 'Gold Feed API Key (Tùy chọn)',
                        controller: _feedController,
                        hint: 'Kitco / Yahoo Finance / GoldAPI...',
                        helper: 'Dùng cho luồng cấp phát giá vàng trực tuyến mở rộng.',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveKeys,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AurumColors.gold,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Lưu Tất Cả API Keys',
                            style: TextStyle(color: Color(0xFF141002), fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Thiết lập thông báo đẩy Android
                _buildSectionHeader('Thông Báo Đẩy Android Đa Kênh', Icons.notifications_active_outlined),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AurumColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AurumColors.border),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Bật Thông Báo Hệ Thống', style: TextStyle(color: AurumColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                        subtitle: const Text('Cảnh báo đẩy trực tiếp lên thanh thông báo Android', style: TextStyle(color: AurumColors.textMuted, fontSize: 10.5)),
                        value: settings.enableNotifications,
                        activeColor: AurumColors.gold,
                        onChanged: (val) {
                          widget.controller.updateSettings(settings.copyWith(enableNotifications: val));
                        },
                      ),
                      const Divider(height: 14, color: AurumColors.borderSubtle),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Cảnh Báo Săn Đáy (Dip-Buying)', style: TextStyle(color: AurumColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                        subtitle: const Text('Rung và báo ngay khi vàng giảm > 3% hoặc RSI < 35', style: TextStyle(color: AurumColors.textMuted, fontSize: 10.5)),
                        value: settings.enableDipAlerts,
                        activeColor: AurumColors.emerald,
                        onChanged: (val) {
                          widget.controller.updateSettings(settings.copyWith(enableDipAlerts: val));
                        },
                      ),
                      const Divider(height: 14, color: AurumColors.borderSubtle),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Nhắc Nhở Tích Sản Ngày Lương', style: TextStyle(color: AurumColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                        subtitle: Text('Nhắc trích mua vàng vào ngày ${settings.dcaReminderDayOfMonth} hàng tháng', style: const TextStyle(color: AurumColors.textMuted, fontSize: 10.5)),
                        value: settings.enableDcaReminder,
                        activeColor: AurumColors.sapphire,
                        onChanged: (val) {
                          widget.controller.updateSettings(settings.copyWith(enableDcaReminder: val));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Nhập/Xuất tệp CSV Bảng giá lịch sử
                _buildSectionHeader('Dữ Liệu Giá Vàng Lịch Sử (CSV)', Icons.file_copy_outlined),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AurumColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AurumColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Định dạng CSV: mỗi dòng "năm,giá_vnd_mỗi_chỉ".\nViệc nhập file sẽ thay thế bảng tham chiếu 2006–2026 trong tab Tích Sản Lãi Kép.',
                        style: TextStyle(color: AurumColors.textMuted, fontSize: 11, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _csvImportController,
                        maxLines: 4,
                        style: const TextStyle(color: AurumColors.textPrimary, fontSize: 11, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          hintText: '2006,1150000\n2007,1450000\n2008,1780000...',
                          filled: true,
                          fillColor: AurumColors.bgPanel,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AurumColors.border)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _importCsv,
                              icon: const Icon(Icons.file_upload_outlined, size: 16),
                              label: const Text('Nhập CSV Dán'),
                              style: OutlinedButton.styleFrom(foregroundColor: AurumColors.goldBright, side: const BorderSide(color: AurumColors.borderGold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final csv = widget.controller.exportHistoricalPricesCsv();
                                _csvImportController.text = csv;
                              },
                              icon: const Icon(Icons.copy_outlined, size: 16),
                              label: const Text('Xem CSV Hiện Tại'),
                              style: OutlinedButton.styleFrom(foregroundColor: AurumColors.textSecondary, side: const BorderSide(color: AurumColors.border)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AurumColors.gold, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: AurumColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildKeyField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String helper,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: AurumColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: AurumColors.bgPanel,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AurumColors.border)),
          ),
        ),
        const SizedBox(height: 3),
        Text(helper, style: const TextStyle(color: AurumColors.textMuted, fontSize: 9.5)),
      ],
    );
  }
}
