import 'dart:math' as math;

/// Tiện ích thuật toán định lượng & tính toán tài chính
class MathUtils {
  MathUtils._();

  /// Nội suy tuyến tính giữa 2 giá trị
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Giới hạn giá trị trong khoảng [min, max]
  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Tính Tỷ lệ tăng trưởng kép hàng năm (CAGR)
  static double calculateCagr({
    required double startValue,
    required double endValue,
    required double years,
  }) {
    if (startValue <= 0 || endValue <= 0 || years <= 0) return 0.0;
    return (math.pow(endValue / startValue, 1.0 / years) - 1.0) * 100.0;
  }

  /// Tính độ lệch chuẩn (Standard Deviation)
  static double standardDeviation(List<double> values) {
    if (values.length < 2) return 0.0;
    final double mean = values.reduce((a, b) => a + b) / values.length;
    final double sumSquares = values.fold(0.0, (acc, v) => acc + math.pow(v - mean, 2));
    return math.sqrt(sumSquares / (values.length - 1));
  }

  /// Tính Trung bình động đơn giản (SMA)
  static List<double> calculateSma(List<double> prices, int period) {
    if (prices.length < period) return [];
    final List<double> sma = [];
    double currentSum = 0.0;

    for (int i = 0; i < prices.length; i++) {
      currentSum += prices[i];
      if (i >= period) {
        currentSum -= prices[i - period];
      }
      if (i >= period - 1) {
        sma.add(currentSum / period);
      }
    }
    return sma;
  }

  /// Tính Trung bình động hàm mũ (EMA)
  static List<double> calculateEma(List<double> prices, int period) {
    if (prices.length < period) return [];
    final List<double> ema = [];
    final double multiplier = 2.0 / (period + 1);

    // Bắt đầu bằng SMA cho chu kỳ đầu tiên
    double initialSum = 0.0;
    for (int i = 0; i < period; i++) {
      initialSum += prices[i];
    }
    double currentEma = initialSum / period;
    ema.add(currentEma);

    for (int i = period; i < prices.length; i++) {
      currentEma = (prices[i] - currentEma) * multiplier + currentEma;
      ema.add(currentEma);
    }
    return ema;
  }

  /// Tính Chỉ số Sức mạnh Tương đối (RSI 14 chu kỳ)
  static double calculateRsi(List<double> prices, {int period = 14}) {
    if (prices.length < period + 1) return 50.0;

    double gainSum = 0.0;
    double lossSum = 0.0;

    for (int i = 1; i <= period; i++) {
      final double diff = prices[i] - prices[i - 1];
      if (diff >= 0) {
        gainSum += diff;
      } else {
        lossSum += diff.abs();
      }
    }

    double avgGain = gainSum / period;
    double avgLoss = lossSum / period;

    for (int i = period + 1; i < prices.length; i++) {
      final double diff = prices[i] - prices[i - 1];
      if (diff >= 0) {
        avgGain = (avgGain * (period - 1) + diff) / period;
        avgLoss = (avgLoss * (period - 1)) / period;
      } else {
        avgGain = (avgGain * (period - 1)) / period;
        avgLoss = (avgLoss * (period - 1) + diff.abs()) / period;
      }
    }

    if (avgLoss == 0) return 100.0;
    final double rs = avgGain / avgLoss;
    return 100.0 - (100.0 / (1.0 + rs));
  }

  /// Tính độ sụt giảm từ đỉnh (Drawdown %)
  static double calculateDrawdown({required double currentPrice, required double peakPrice}) {
    if (peakPrice <= 0) return 0.0;
    return ((currentPrice - peakPrice) / peakPrice) * 100.0;
  }
}
