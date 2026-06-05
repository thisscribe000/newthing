import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WavelineColors {
  static const Color bg = Color(0xFF12082A);
  static const Color surface = Color(0xFF1A0F35);
  static const Color surface2 = Color(0xFF23184A);
  static const Color surface3 = Color(0xFF2D2158);
  static const Color border = Color(0x33FFFFFF);
  static const Color borderLight = Color(0x1AFFFFFF);
  static const Color accent = Color(0xFFAB47BC);
  static const Color accentLight = Color(0xFFCE73E0);
  static const Color accentDark = Color(0xFF7B2D8E);
  static const Color pink = Color(0xFFFF3D5A);
  static const Color gold = Color(0xFFF5C842);
  static const Color cyan = Color(0xFF00D4AA);
  static const Color orange = Color(0xFFFF8A65);
  static const Color textPrimary = Color(0xFFF3E5F5);
  static const Color textSecondary = Color(0xFFE1BEE7);
  static const Color textMuted = Color(0xFF9575CD);
  static const Color textDim = Color(0xFF7A5DA8);

  static const List<Color> gradientStart = [Color(0xFF2D1060), Color(0xFF12082A)];
  static const List<Color> gradientPlayer = [Color(0xFF2D1060), Color(0xFF1A0F35)];
}

class WavelineTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: WavelineColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: WavelineColors.accent,
        secondary: WavelineColors.pink,
        tertiary: WavelineColors.cyan,
        surface: WavelineColors.surface,
        surfaceContainerLow: WavelineColors.surface,
        surfaceContainer: WavelineColors.surface2,
        surfaceContainerHigh: WavelineColors.surface3,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: WavelineColors.textPrimary,
        onSurfaceVariant: WavelineColors.textMuted,
        outline: WavelineColors.border,
        outlineVariant: WavelineColors.borderLight,
        error: WavelineColors.pink,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.nunito(fontSize: 48, fontWeight: FontWeight.w800, color: WavelineColors.textPrimary, letterSpacing: -1),
        displayMedium: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w700, color: WavelineColors.textPrimary, letterSpacing: -0.5),
        headlineLarge: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w700, color: WavelineColors.textPrimary),
        headlineMedium: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w700, color: WavelineColors.textPrimary),
        headlineSmall: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w600, color: WavelineColors.textPrimary),
        titleLarge: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600, color: WavelineColors.textPrimary),
        titleMedium: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: WavelineColors.textPrimary),
        titleSmall: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: WavelineColors.textPrimary),
        bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: WavelineColors.textSecondary),
        bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: WavelineColors.textSecondary),
        bodySmall: GoogleFonts.dmSans(fontSize: 12, color: WavelineColors.textMuted),
        labelLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: WavelineColors.textPrimary),
        labelMedium: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: WavelineColors.textMuted),
        labelSmall: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: WavelineColors.textDim),
      ),
      cardTheme: CardThemeData(
        color: WavelineColors.surface2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: WavelineColors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: WavelineColors.bg.withValues(alpha: 0.95),
        indicatorColor: WavelineColors.accent.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: WavelineColors.accent);
          }
          return GoogleFonts.dmSans(fontSize: 11, color: WavelineColors.textMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(size: 24, color: WavelineColors.accent);
          }
          return IconThemeData(size: 24, color: WavelineColors.textMuted);
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        modalBarrierColor: Color(0x80000000),
        shape: RoundedRectangleBorder(),
      ),
      dividerTheme: DividerThemeData(
        color: WavelineColors.border,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: WavelineColors.surface3,
        contentTextStyle: GoogleFonts.dmSans(fontSize: 13, color: WavelineColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WavelineColors.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: WavelineColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: WavelineColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: WavelineColors.accent.withValues(alpha: 0.5), width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: WavelineColors.textDim),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: WavelineColors.accent,
        inactiveTrackColor: WavelineColors.border,
        thumbColor: WavelineColors.accent,
        overlayColor: WavelineColors.accent.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
    );
  }
}
