import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/gold_unit_converter.dart';
import '../../controllers/gold_vault_controller.dart';
import '../../controllers/market_intelligence_controller.dart';
import '../../widgets/cards/multi_asset_card.dart';
import '../../widgets/cards/vault_summary_card.dart';
import '../../widgets/charts/portfolio_donut_painter.dart';
import '../../widgets/common/aurum_logo.dart';
import '../../widgets/common/aurum_segmented_pill.dart';
import '../../widgets/common/aurum_slider_field.dart';
import '../modals/add_vault_transaction_sheet.dart';

/// Tab 5: Két Vàng Cá Nhân & Phân Bổ Danh Mục 80-20
class GoldVaultTab extends StatelessWidget {
  final GoldVaultController controller;
  final MarketIntelligenceController marketController;

  const GoldVaultTab({
    super.key,
    required this.controller,
    required this.marketController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final summary = controller.getSummary();
        final items = controller.items;
        final allocation = controller.allocation8020;
        final comparison = controller.multiAssetComparison;
        final snap = marketController.snapshot;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Thẻ tổng quan tài sản Két Vàng
              VaultSummaryCard(
                summary: summary,
                onAddTap: () => _openAddTransactionSheet(context),
              ),
              const SizedBox(height: 14),

              // 2. Thanh chuyển đổi phân hệ con
              AurumSegmentedPill<VaultSubTab>(
                items: const [
                  SegmentItem(value: VaultSubTab.safeItems, label: 'Sổ Két Vàng', icon: Icons.inventory_2_outlined),
                  SegmentItem(value: VaultSubTab.rule8020, label: 'Rổ 80-20', icon: Icons.pie_chart_outline),
                  SegmentItem(value: VaultSubTab.comparison, label: 'So Sánh 3 Kênh', icon: Icons.compare_arrows),
                ],
                selectedValue: controller.subTab,
                onSelected: (tab) => controller.setSubTab(tab),
              ),
              const SizedBox(height: 14),

              // 3. Nội dung theo phân hệ con
              if (controller.subTab == VaultSubTab.safeItems) ...[
                _buildVaultItemsList(context, items, snap),
              ] else if (controller.subTab == VaultSubTab.rule8020) ...[
                _build8020Section(allocation),
              ] else ...[
                _buildComparisonSection(comparison),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVaultItemsList(BuildContext context, List<dynamic> items, dynamic snap) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: AurumColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AurumColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.lock_clock_outlined, color: AurumColors.textMuted, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Két vàng chưa có món nào được ghi nhận',
              style: TextStyle(color: AurumColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bấm "Thêm Vàng" để ghi lại các giao dịch mua vàng nhẫn, SJC của bạn.',
              style: TextStyle(color: AurumColors.textMuted, fontSize: 11.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => _openAddTransactionSheet(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Thêm Món Vàng Đầu Tiên'),
              style: ElevatedButton.styleFrom(backgroundColor: AurumColors.gold),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final currentVal = item.currentMarketValue(
          currentRingPricePerChi: snap.ringSellPerChi,
          currentSjcPricePerLuong: snap.sjcSellPerLuong,
        );
        final profit = item.netProfit(
          currentRingPricePerChi: snap.ringSellPerChi,
          currentSjcPricePerLuong: snap.sjcSellPerLuong,
        );
        final roi = item.roiPercent(
          currentRingPricePerChi: snap.ringSellPerChi,
          currentSjcPricePerLuong: snap.sjcSellPerLuong,
        );
        final bool isProfit = profit >= 0;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AurumColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AurumColors.border),
          ),
          child: Row(
            children: [
              const AurumLogo(size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(color: AurumColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.brandDisplayName} · ${item.productDisplayName}',
                      style: const TextStyle(color: AurumColors.goldBright, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${GoldUnitConverter.fmtChi(item.totalChi, decimals: 2)} (${item.quantity} ${item.unitDisplayName}) · Mua ${DateFormatter.formatDate(item.purchaseDate)}',
                      style: const TextStyle(color: AurumColors.textMuted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.fmtVnd(currentVal),
                    style: const TextStyle(color: AurumColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isProfit ? '+' : ''}${CurrencyFormatter.fmtVnd(profit)} (${CurrencyFormatter.fmtPercent(roi)})',
                    style: TextStyle(
                      color: isProfit ? AurumColors.emerald : AurumColors.ruby,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AurumColors.textMuted, size: 18),
                onPressed: () => controller.deleteItem(item.id),
                padding: const EdgeInsets.only(left: 8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build8020Section(dynamic allocation) {
    final segments = [
      DonutSegment(
        label: 'Sinh Hoạt (80% lương)',
        value: allocation.livingExpenseVnd,
        color: AurumColors.sapphire,
      ),
      DonutSegment(
        label: 'Gửi Tiết Kiệm (Thanh khoản)',
        value: allocation.monthlyLiquidSavingsVnd,
        color: AurumColors.emerald,
      ),
      DonutSegment(
        label: 'Vàng Nhẫn (Phòng thủ dài hạn)',
        value: allocation.monthlyGoldVnd,
        color: AurumColors.gold,
      ),
    ];

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
          const Text(
            'Mô Hình Rổ Tài Sản "80-20" Phòng Thủ Lạm Phát',
            style: TextStyle(color: AurumColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Trích 20% thu nhập tiết kiệm, chia nhỏ 80% gửi ngân hàng thanh khoản & 20% đổi sang vàng nhẫn 9999.',
            style: TextStyle(color: AurumColors.textMuted, fontSize: 11, height: 1.35),
          ),
          const SizedBox(height: 16),

          Center(
            child: PortfolioDonutChart(
              segments: segments,
              centerTitle: CurrencyFormatter.fmtVnd(allocation.monthlyIncome),
              centerSubtitle: 'Thu nhập / tháng',
            ),
          ),
          const SizedBox(height: 16),

          // 3 Thẻ chi tiết phân bổ
          _buildAllocationPill('Chi tiêu sinh hoạt', CurrencyFormatter.fmtVnd(allocation.livingExpenseVnd), AurumColors.sapphire),
          const SizedBox(height: 8),
          _buildAllocationPill('Tiết kiệm ngân hàng (Thanh khoản)', CurrencyFormatter.fmtVnd(allocation.monthlyLiquidSavingsVnd), AurumColors.emerald),
          const SizedBox(height: 8),
          _buildAllocationPill('Tích lũy vàng nhẫn trơn 9999', CurrencyFormatter.fmtVnd(allocation.monthlyGoldVnd), AurumColors.gold),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AurumColors.bgPanel,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AurumColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AurumColors.gold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mục tiêu quỹ khẩn cấp 6 tháng chi phí: ${CurrencyFormatter.fmtVnd(allocation.targetEmergencyFundVnd)}',
                    style: const TextStyle(color: AurumColors.goldBright, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationPill(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AurumColors.bgPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11.5)),
            ],
          ),
          Text(amount, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(dynamic comparison) {
    return Column(
      children: [
        MultiAssetComparisonCard(comparison: comparison),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AurumColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AurumColors.border),
          ),
          child: Column(
            children: [
              AurumSliderField(
                label: 'Số Tiền Tích Lũy Hàng Tháng',
                value: comparison.monthlyDeposit,
                min: 1000000,
                max: 20000000,
                divisions: 19,
                displayValue: CurrencyFormatter.fmtVnd(comparison.monthlyDeposit),
                onChanged: (val) => controller.updateMultiAssetComparison(
                  monthlyDeposit: val,
                  years: comparison.years,
                ),
              ),
              const SizedBox(height: 8),
              AurumSliderField(
                label: 'Thời Gian Đầu Tư',
                value: comparison.years.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                displayValue: '${comparison.years} năm',
                onChanged: (val) => controller.updateMultiAssetComparison(
                  monthlyDeposit: comparison.monthlyDeposit,
                  years: val.round(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddVaultTransactionSheet(controller: controller),
    );
  }
}
