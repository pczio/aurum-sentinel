import 'dart:math' as math;
import '../models/macro_indicators.dart';

/// Cỗ máy định lượng Giá trị hợp lý vĩ mô của Vàng (Gold Macro Fair Value Engine)
/// Mô hình dựa trên mối tương quan nghịch đảo chủ đạo giữa Lợi suất thực TIPS 10Y và Sức mạnh đồng USD DXY:
/// P* = alpha - beta * TIPS_10Y - gamma * ln(DXY) + delta * CB_NetBuy
class MacroValuationEngine {
  MacroValuationEngine._();

  static const double defaultAlpha = 5200.0;
  static const double defaultBetaTips = 65.0;     // Trọng số nghịch đảo TIPS (mỗi 1% TIPS làm giảm ~65 USD)
  static const double defaultGammaDxy = 450.0;    // Tác động nghịch đảo của ln(DXY)
  static const double defaultDeltaCb = 3.5;       // Lực nâng đỡ từ mua ròng của các NHTW

  /// Tính toán giá trị hợp lý P* của XAU/USD
  static MacroIndicators evaluateMacroFairValue({
    required double tips10Y,
    required double dxy,
    required double cbNetBuyTons,
    required double marketPriceXau,
    double alpha = defaultAlpha,
    double betaTips = defaultBetaTips,
    double gammaDxy = defaultGammaDxy,
    double deltaCb = defaultDeltaCb,
  }) {
    // P* = alpha - beta * TIPS - gamma * ln(DXY) + delta * CB
    final double lnDxy = dxy > 0 ? math.log(dxy) : math.log(104.0);
    final double fairValue = alpha - (betaTips * tips10Y) - (gammaDxy * lnDxy) + (deltaCb * cbNetBuyTons);

    return MacroIndicators(
      tips10Y: tips10Y,
      dxy: dxy,
      cbNetBuyTons: cbNetBuyTons,
      fairValueXau: fairValue > 0 ? fairValue : marketPriceXau,
      marketPriceXau: marketPriceXau,
      updatedAt: DateTime.now(),
    );
  }
}
