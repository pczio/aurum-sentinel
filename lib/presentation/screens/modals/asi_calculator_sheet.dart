import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../controllers/market_intelligence_controller.dart';
import '../../../domain/engines/arbitrage_engine.dart';
import '../../../domain/models/arbitrage_result.dart';

/// Modal bảng tính chi tiết SJC Arbitrage Spread Index (ASI)
class AsiCalculatorSheet extends StatefulWidget {
  final MarketIntelligenceController controller;

  const AsiCalculatorSheet({super.key, required this.controller});

  @override
  State<AsiCalculatorSheet> createState() => _AsiCalculatorSheetState();
}

class _AsiCalculatorSheetState extends State<AsiCalculatorSheet> {
  late TextEditingController _xauController;
  late TextEditingController _usdController;
  late TextEditingController _sjcController;
  late TextEditingController _feeController;

  late ArbitrageResult _currentResult;

  @override
  void initState() {
    super.initState();
    final snap = widget.controller.snapshot;
    _xauController = TextEditingController(text: snap.xauUsd.toStringAsFixed(1));
    _usdController = TextEditingController(text: snap.usdVnd.toStringAsFixed(0));
    _sjcController = TextEditingController(text: snap.sjcSellPerLuong.toStringAsFixed(0));
    _feeController = TextEditingController(text: '500000');
    _recalculate();
  }

  void _recalculate() {
    final xau = CurrencyFormatter.parseFloat(_xauController.text, 4450.0);
    final usd = CurrencyFormatter.parseFloat(_usdController.text, 26200.0);
    final sjc = CurrencyFormatter.parseVnd(_sjcController.text, 148000000.0);
    final fee = CurrencyFormatter.parseVnd(_feeController.text, 500000.0);

    setState(() {
      _currentResult = ArbitrageEngine.calculateAsi(
        xauUsd: xau,
        usdVnd: usd,
        sjcSellPrice: sjc,
        taxAndFee: fee,
      );
    });
  }

  @override
  void dispose() {
    _xauController.dispose();
    _usdController.dispose();
    _sjcController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AurumColors.bgCardElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.balance, color: AurumColors.gold, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Máy Tính Chênh Lệch ASI Chuyên Sâu',
                      style: TextStyle(
                        color: AurumColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AurumColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'ASI = Giá SJC − (XAU_spot × USD/VND ÷ 31.1035 × 37.5 + Thuế/Phí)\nNgưỡng an toàn: ASI ≤ 5.0 triệu/lượng.',
              style: TextStyle(color: AurumColors.textMuted, fontSize: 11, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Kết quả ASI nổi bật
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AurumColors.bgPanel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _currentResult.statusColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Chênh Lệch Thực Tế (ASI)', style: TextStyle(color: AurumColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.fmtVnd(_currentResult.asi),
                          style: TextStyle(
                            color: _currentResult.statusColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          _currentResult.title,
                          style: TextStyle(color: _currentResult.statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Thế Giới Quy Đổi', style: TextStyle(color: AurumColors.textMuted, fontSize: 11)),
                      Text(
                        CurrencyFormatter.fmtVnd(_currentResult.worldConvertedPerLuong),
                        style: const TextStyle(color: AurumColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Premium: +${_currentResult.premiumPercent.toStringAsFixed(1)}%',
                        style: TextStyle(color: _currentResult.statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Các ô nhập tham số
            Row(
              children: [
                Expanded(child: _buildInput('XAU/USD Spot', _xauController, 'USD/oz')),
                const SizedBox(width: 12),
                Expanded(child: _buildInput('Tỷ giá USD/VND', _usdController, 'đ')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInput('Giá SJC Bán Ra', _sjcController, 'VND/lượng')),
                const SizedBox(width: 12),
                Expanded(child: _buildInput('Thuế & Phí', _feeController, 'đ/lượng')),
              ],
            ),
            const SizedBox(height: 20),

            // Nút áp dụng vào màn hình chính
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final xau = CurrencyFormatter.parseFloat(_xauController.text, 4450.0);
                  final usd = CurrencyFormatter.parseFloat(_usdController.text, 26200.0);
                  final sjc = CurrencyFormatter.parseVnd(_sjcController.text, 148000000.0);
                  final fee = CurrencyFormatter.parseVnd(_feeController.text, 500000.0);

                  widget.controller.updateManualPrices(
                    xauUsd: xau,
                    usdVnd: usd,
                    sjcSellPerLuong: sjc,
                    ringSellPerChi: widget.controller.snapshot.ringSellPerChi,
                    taxAndFee: fee,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AurumColors.gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Cập Nhật Vào Bảng Điều Khiển',
                  style: TextStyle(color: Color(0xFF141002), fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AurumColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AurumColors.bgPanel,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            suffixText: suffix,
            suffixStyle: const TextStyle(color: AurumColors.gold, fontSize: 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AurumColors.border)),
          ),
          onChanged: (_) => _recalculate(),
        ),
      ],
    );
  }
}
