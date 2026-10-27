import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/aurum_colors.dart';

/// Chủ đề hiển thị Dark & Gold Obsidian Luxury cho toàn bộ ứng dụng AurumSentinel
class AurumTheme {
  AurumTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = ThemeData.dark().textTheme;
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme).copyWith(
      displayLarge: const TextStyle(color: AurumColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: -1.0),
      displayMedium: const TextStyle(color: AurumColors.textPrimary, fontWeight: FontWeight.bold, letterSpacing: -0.8),
      headlineMedium: const TextStyle(color: AurumColors.textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineSmall: const TextStyle(color: AurumColors.textPrimary, fontWeight: FontWeight.w700),
      titleLarge: const TextStyle(color: AurumColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
      titleMedium: const TextStyle(color: AurumColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
      titleSmall: const TextStyle(color: AurumColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
      bodyLarge: const TextStyle(color: AurumColors.textPrimary, fontSize: 15, height: 1.45),
      bodyMedium: const TextStyle(color: AurumColors.textSecondary, fontSize: 13, height: 1.4),
      bodySmall: const TextStyle(color: AurumColors.textMuted, fontSize: 11),
      labelLarge: const TextStyle(color: AurumColors.textPrimary, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AurumColors.bgRoot,
      colorScheme: const ColorScheme.dark(
        primary: AurumColors.gold,
        onPrimary: Color(0xFF141002),
        primaryContainer: AurumColors.goldDark,
        onPrimaryContainer: AurumColors.goldBright,
        secondary: AurumColors.sapphire,
        onSecondary: Colors.white,
        surface: AurumColors.bgPanel,
        onSurface: AurumColors.textPrimary,
        error: AurumColors.ruby,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      cardColor: AurumColors.bgCard,
      cardTheme: CardThemeData(
        color: AurumColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AurumColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AurumColors.bgRoot,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AurumColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AurumColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AurumColors.bgPanel,
        selectedItemColor: AurumColors.gold,
        unselectedItemColor: AurumColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AurumColors.bgPanel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AurumColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AurumColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AurumColors.gold, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AurumColors.textMuted, fontSize: 13),
        labelStyle: const TextStyle(color: AurumColors.textSecondary, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AurumColors.gold,
          foregroundColor: const Color(0xFF141002),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AurumColors.gold,
          side: const BorderSide(color: AurumColors.gold, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AurumColors.border,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
