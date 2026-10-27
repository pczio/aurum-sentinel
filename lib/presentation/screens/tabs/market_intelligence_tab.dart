import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../controllers/market_intelligence_controller.dart';
import '../../widgets/cards/arbitrage_gauge_card.dart';
import '../../widgets/cards/gold_price_ticker_card.dart';
import '../../widgets/cards/macro_valuation_card.dart';
import '../modals/asi_calculator_sheet.dart';

/// Tab 1: Thị Trường Vàng & Arbitrage SJC
class MarketIntelligenceTab extends StatelessWidget {
  final MarketIntelligenceController controller;

  const MarketIntelligenceTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final snap = controller.snapshot;
        final arbitrage = controller.arbitrageResult;
        final macro = controller.macroIndicators;

        return RefreshIndicator(
          onRefresh: () async {
            controller.loadMacroData();
          },
          color: AurumColors.gold,
          backgroundColor: AurumColors.bgPanel,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh điều khiển Live Tick Stream & Cập nhật giá thủ công
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: controller.isAutoTicking ? AurumColors.emerald : AurumColors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.isAutoTicking ? 'STREAMING GIÁ SỐNG' : 'DỮ LIỆU TĨNH',
                          style: TextStyle(
                            color: controller.isAutoTicking ? AurumColors.emerald : AurumColors.textMuted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: controller.toggleAutoTick,
                          icon: Icon(
                            controller.isAutoTicking ? Icons.pause_circle_outline : Icons.play_circle_outline,
                            size: 16,
                            color: AurumColors.gold,
                          ),
                          label: Text(
                            controller.isAutoTicking ? 'Dừng Giả Lập' : 'Chạy Giả Lập Tick',
                            style: const TextStyle(color: AurumColors.gold, fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                        ),
                        const SizedBox(width: 4),
                        OutlinedButton.icon(
                          onPressed: () => _showManualUpdateDialog(context),
                          icon: const Icon(Icons.edit_note, size: 16),
                          label: const Text('Nhập Giá'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AurumColors.goldBright,
                            side: const BorderSide(color: AurumColors.borderGold),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 1. Ma trận 4 thẻ giá vàng chủ đạo
                GoldPriceTickerMatrix(
                  snapshot: snap,
                  arbitrage: arbitrage,
                  onAsiTap: () => _openAsiCalculator(context),
                ),
                const SizedBox(height: 14),

                // 2. Thẻ thước đo định lượng Arbitrage SJC (ASI)
                ArbitrageGaugeCard(
                  arbitrage: arbitrage,
                  onCalculateTap: () => _openAsiCalculator(context),
                ),
                const SizedBox(height: 14),

                // 3. Thẻ định giá vĩ mô XAU Fair Value P*
                if (macro != null) ...[
                  MacroValuationCard(macro: macro),
                  const SizedBox(height: 14),
                ],

                // 4. Bảng giá các thương hiệu vàng lớn trong nước
                _buildDomesticBrandSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDomesticBrandSection() {
    final brands = controller.brandPrices;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.store_mall_directory_outlined, color: AurumColors.gold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Giá Vàng Các Thương Hiệu Việt Nam',
                    style: TextStyle(
                      color: AurumColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                'Mua Vào · Bán Ra',
                style: TextStyle(color: AurumColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: brands.length,
            separatorBuilder: (_, _) => const Divider(height: 16, color: AurumColors.borderSubtle),
            itemBuilder: (context, index) {
              final b = brands[index];
              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AurumColors.bgPanel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AurumColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      b.brandName.substring(0, b.brandName.length >= 2 ? 2 : 1).toUpperCase(),
                      style: const TextStyle(
                        color: AurumColors.goldBright,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.brandName,
                          style: const TextStyle(
                            color: AurumColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.productName,
                          style: const TextStyle(color: AurumColors.textMuted, fontSize: 10.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Bán: ${CurrencyFormatter.fmtVnd(b.sellPrice)}',
                        style: const TextStyle(
                          color: AurumColors.goldBright,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mua: ${CurrencyFormatter.fmtVnd(b.buyPrice)} (Spread: ${CurrencyFormatter.fmtVnd(b.spread)})',
                        style: const TextStyle(color: AurumColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _openAsiCalculator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AsiCalculatorSheet(controller: controller),
    );
  }

  void _showManualUpdateDialog(BuildContext context) {
    final snap = controller.snapshot;
    final xauController = TextEditingController(text: snap.xauUsd.toStringAsFixed(1));
    final usdController = TextEditingController(text: snap.usdVnd.toStringAsFixed(0));
    final sjcController = TextEditingController(text: snap.sjcSellPerLuong.toStringAsFixed(0));
    final ringController = TextEditingController(text: snap.ringSellPerChi.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AurumColors.bgCardElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.edit_note, color: AurumColors.gold),
              SizedBox(width: 8),
              Text('Cập Nhật Giá Thủ Công', style: TextStyle(color: AurumColors.textPrimary, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField('XAU/USD Spot (USD/oz)', xauController),
                const SizedBox(height: 10),
                _buildDialogField('Tỷ giá USD/VND', usdController),
                const SizedBox(height: 10),
                _buildDialogField('Giá SJC Bán Ra (VND/lượng)', sjcController),
                const SizedBox(height: 10),
                _buildDialogField('Giá Nhẫn 9999 (VND/chỉ)', ringController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AurumColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final xau = CurrencyFormatter.parseFloat(xauController.text, snap.xauUsd);
                final usd = CurrencyFormatter.parseFloat(usdController.text, snap.usdVnd);
                final sjc = CurrencyFormatter.parseVnd(sjcController.text, snap.sjcSellPerLuong);
                final ring = CurrencyFormatter.parseVnd(ringController.text, snap.ringSellPerChi);

                controller.updateManualPrices(
                  xauUsd: xau,
                  usdVnd: usd,
                  sjcSellPerLuong: sjc,
                  ringSellPerChi: ring,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AurumColors.gold),
              child: const Text('Áp Dụng', style: TextStyle(color: Color(0xFF141002), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogField(String label, TextEditingController textController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AurumColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AurumColors.bgPanel,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AurumColors.border)),
          ),
        ),
      ],
    );
  }
}
