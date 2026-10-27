import 'package:flutter/material.dart';

/// Bảng màu Obsidian & Metallic Gold sang trọng dành cho AurumSentinel
class AurumColors {
  AurumColors._();

  // Nền & Khối (Backgrounds & Surfaces)
  static const Color bgRoot = Color(0xFF07090E);          // Đen thẳm Obsidian
  static const Color bgPanel = Color(0xFF0F131C);         // Panel xám than sâu
  static const Color bgCard = Color(0xFF151A26);          // Thẻ tài chính nổi
  static const Color bgCardHover = Color(0xFF1D2436);     // Thẻ khi hover/active
  static const Color bgCardElevated = Color(0xFF222B40);  // Thẻ nâng cao
  static const Color bgGlass = Color(0xCC151A26);         // Thẻ hiệu ứng kính mờ
  
  // Viền & Phân cách (Borders & Dividers)
  static const Color border = Color(0xFF232B3E);          // Viền mặc định
  static const Color borderSubtle = Color(0xFF182030);    // Viền nhẹ
  static const Color borderGold = Color(0x66E6B94D);      // Viền vàng kim tinh tế
  static const Color borderEmerald = Color(0x6600E676);   // Viền xanh lá lãi
  static const Color borderRuby = Color(0x66FF453A);      // Viền đỏ lỗ

  // Sắc tố Vàng Kim (Liquid Gold Accents)
  static const Color gold = Color(0xFFE6B94D);            // Vàng hoàng kim chuẩn
  static const Color goldBright = Color(0xFFFFD873);      // Vàng ánh kim sáng
  static const Color goldDim = Color(0xFF8A712F);         // Vàng trầm sang trọng
  static const Color goldDark = Color(0xFF4A3C16);        // Nền vàng sẫm
  static const Color goldGradientStart = Color(0xFFFFE082);
  static const Color goldGradientEnd = Color(0xFFD4AF37);

  // Trạng thái thị trường & Chỉ số (Financial Status)
  static const Color emerald = Color(0xFF00E676);         // Lãi, Tăng trưởng, Mua an toàn
  static const Color emeraldDim = Color(0xFF0A4024);
  static const Color ruby = Color(0xFFFF453A);            // Giảm, Lỗ, Rủi ro chênh lệch cao
  static const Color rubyDim = Color(0xFF4D1412);
  static const Color sapphire = Color(0xFF3A86FF);        // XAU Spot, Lãi suất, Vĩ mô
  static const Color sapphireDim = Color(0xFF10284D);
  static const Color amethyst = Color(0xFFA855F7);        // Arbitrage ASI, Phân tích kỹ thuật
  static const Color amethystDim = Color(0xFF33144D);
  static const Color amber = Color(0xFFFFAB00);           // Cảnh báo, Hold, Trung tính
  static const Color cyan = Color(0xFF00E5FF);            // Dữ liệu FRED, PBoC

  // Phông chữ & Văn bản (Typography)
  static const Color textPrimary = Color(0xFFF4F6FB);     // Trắng ngà chính
  static const Color textSecondary = Color(0xFF9AA4B8);   // Xám sáng phụ
  static const Color textMuted = Color(0xFF5D677D);       // Xám chìm chú thích
  static const Color textGold = Color(0xFFFFD873);        // Chữ vàng nhấn mạnh

  // Màu sắc cho các mức tích lũy (% lương)
  static const List<Color> levelColors = [
    Color(0xFFE6B94D), // Mức 1 (10% - Vàng kim)
    Color(0xFF3A86FF), // Mức 2 (15% - Lam sapphire)
    Color(0xFF00E676), // Mức 3 (20% - Lục bảo ngọc)
    Color(0xFFA855F7), // Mức 4 (25% - Tím thạch anh)
    Color(0xFFFF9100), // Mức 5 (30% - Cam hổ phách)
    Color(0xFFFF4081), // Mức 6 (Tùy biến - Hồng ngọc)
  ];

  // Gradients kim loại quý cao cấp
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldGradientStart, goldGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x1AE6B94D), Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
