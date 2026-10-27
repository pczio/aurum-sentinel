import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/arbitrage_result.dart';
import '../../../domain/models/gold_price_snapshot.dart';
import 'aurum_stat_card.dart';

/// Bảng 4 thẻ chỉ số giá vàng then chốt (XAU, SJC, Nhẫn 9999, ASI)
class GoldPriceTickerMatrix extends StatelessWidget {
  final GoldPriceSnapshot snapshot;
  final ArbitrageResult arbitrage;
  final VoidCallback? onAsiTap;
  final VoidCallback? onManualUpdateTap;

  const GoldPriceTickerMatrix({
    super.key,
    required this.snapshot,
    required this.arbitrage,
    this.onAsiTap,
    this.onManualUpdateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AurumStatCard(
                title: 'XAU/USD Spot',
                value: CurrencyFormatter.fmtUsd(snapshot.xauUsd),
                subtitle: '${CurrencyFormatter.fmtPercent(snapshot.xauUsdChange24h)} · 24h',
                accentColor: snapshot.xauUsdChange24h >= 0 ? AurumColors.emerald : AurumColors.ruby,
                icon: Icons.public,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AurumStatCard(
                title: 'Vàng miếng SJC',
                value: CurrencyFormatter.fmtVnd(snapshot.sjcSellPerLuong),
                subtitle: 'VND / lượng',
                accentColor: AurumColors.sapphire,
                icon: Icons.view_agenda_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AurumStatCard(
                title: 'Nhẫn trơn 999.9',
                value: CurrencyFormatter.fmtVnd(snapshot.ringSellPerChi),
                subtitle: 'VND / chỉ',
                accentColor: AurumColors.gold,
                icon: Icons.adjust,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AurumStatCard(
                title: 'Chênh lệch ASI',
                value: CurrencyFormatter.fmtVnd(arbitrage.asi),
                subtitle: arbitrage.zone == ArbitrageZone.safe ? 'Vùng mua an toàn' : 'Chênh lệch cao',
                accentColor: arbitrage.statusColor,
                icon: Icons.balance,
                onTap: onAsiTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
