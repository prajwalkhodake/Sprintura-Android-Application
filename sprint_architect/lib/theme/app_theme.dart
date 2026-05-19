import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sprint Architect Design System
/// Inspired by "Regain" — minimalist, serene, wellness-focused.
/// Supports multiple unlockable themes.
class AppTheme {
  // ========== DEFAULT THEME COLORS (Deep Navy + Sage Green) ==========
  static const Color deepNavy = Color(0xFF0A192F);
  static const Color darkNavy = Color(0xFF0D1B2A);
  static const Color midNavy = Color(0xFF1B2838);
  static const Color lightNavy = Color(0xFF233554);
  static const Color slateBlue = Color(0xFF2D4059);

  static const Color sageGreen = Color(0xFF64FFDA);
  static const Color sageGreenDark = Color(0xFF4ECDC4);
  static const Color sageGreenMuted = Color(0xFF3DAA9E);
  static const Color sageGreenSubtle = Color(0x3364FFDA); // 20% opacity

  static const Color softWhite = Color(0xFFE6F1FF);
  static const Color lightGray = Color(0xFFA8B2D1);
  static const Color slateGray = Color(0xFF8892B0);
  static const Color dimGray = Color(0xFF495670);

  static const Color errorRed = Color(0xFFFF6B6B);
  static const Color warningAmber = Color(0xFFFFE66D);
  static const Color successGreen = Color(0xFF4ECDC4);

  static const Color cardBackground = Color(0xFF112240);
  static const Color surfaceColor = Color(0xFF0D1B2A);
  static const Color dividerColor = Color(0xFF233554);

  // ========== GRADIENTS ==========
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sageGreen, sageGreenDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepNavy, darkNavy],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardBackground, Color(0xFF0F1E38)],
  );

  static const LinearGradient coinGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
  );

  // ========== SHADOWS ==========
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: sageGreen.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  // ========== BORDER RADIUS ==========
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 100.0;

  // ========== SPACING ==========
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double spaceXxl = 48.0;

  // ========== PREMIUM THEME DEFINITIONS ==========
  static const Map<String, ThemeColors> themePresets = {
    'default': ThemeColors(
      name: 'Deep Navy',
      background1: Color(0xFF0A192F),
      background2: Color(0xFF0D1B2A),
      card: Color(0xFF112240),
      accent: Color(0xFF64FFDA),
      accentDark: Color(0xFF4ECDC4),
      divider: Color(0xFF233554),
      textPrimary: Color(0xFFE6F1FF),
      textSecondary: Color(0xFFA8B2D1),
      textMuted: Color(0xFF8892B0),
      textDim: Color(0xFF495670),
      icon: '🌊',
    ),
    'sakura': ThemeColors(
      name: 'Midnight Sakura',
      background1: Color(0xFF0D0D0D),
      background2: Color(0xFF1A0A1A),
      card: Color(0xFF1F0F1F),
      accent: Color(0xFFFF8FAB),
      accentDark: Color(0xFFE0607E),
      divider: Color(0xFF2A1A2A),
      textPrimary: Color(0xFFFFF0F5),
      textSecondary: Color(0xFFD4A3B5),
      textMuted: Color(0xFFA07080),
      textDim: Color(0xFF5A3545),
      icon: '🌸',
    ),
    'forest': ThemeColors(
      name: 'Forest Meditation',
      background1: Color(0xFF0A1A0A),
      background2: Color(0xFF0D150D),
      card: Color(0xFF122212),
      accent: Color(0xFFA8D5BA),
      accentDark: Color(0xFF7CB896),
      divider: Color(0xFF1E3A1E),
      textPrimary: Color(0xFFF0F5F0),
      textSecondary: Color(0xFFB0C4B0),
      textMuted: Color(0xFF7A9A7A),
      textDim: Color(0xFF4A6A4A),
      icon: '🌿',
    ),
  };

  /// Get colors for a given theme ID
  static ThemeColors getThemeColors(String themeId) {
    return themePresets[themeId] ?? themePresets['default']!;
  }

  /// Build a ThemeData from a theme ID
  static ThemeData buildTheme(String themeId) {
    final tc = getThemeColors(themeId);
    return _buildThemeData(tc);
  }

  // ========== DEFAULT THEME DATA ==========
  static ThemeData get darkTheme => _buildThemeData(themePresets['default']!);

  static ThemeData _buildThemeData(ThemeColors tc) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: tc.background1,
      colorScheme: ColorScheme.dark(
        primary: tc.accent,
        secondary: tc.accentDark,
        surface: tc.card,
        error: errorRed,
        onPrimary: tc.background1,
        onSecondary: tc.background1,
        onSurface: tc.textPrimary,
        onError: softWhite,
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: tc.textPrimary,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: tc.textPrimary,
            letterSpacing: -0.3,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: tc.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: tc.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: tc.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: tc.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: tc.textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: tc.textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: tc.textMuted,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: tc.accent,
            letterSpacing: 0.5,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: tc.textMuted,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: tc.textPrimary,
        ),
        iconTheme: IconThemeData(color: tc.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: tc.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tc.accent,
          foregroundColor: tc.background1,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tc.accent,
          side: BorderSide(color: tc.accent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tc.background2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: tc.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: tc.accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: tc.textMuted,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.inter(
          color: tc.textSecondary,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tc.background2,
        selectedItemColor: tc.accent,
        unselectedItemColor: tc.textDim,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tc.card,
        contentTextStyle: GoogleFonts.inter(
          color: tc.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: tc.divider,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return tc.accent;
          return tc.textDim;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tc.accent.withValues(alpha: 0.3);
          }
          return tc.divider;
        }),
      ),
    );
  }
}

/// Data class holding all colors for a theme variant.
class ThemeColors {
  final String name;
  final Color background1;
  final Color background2;
  final Color card;
  final Color accent;
  final Color accentDark;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDim;
  final String icon;

  const ThemeColors({
    required this.name,
    required this.background1,
    required this.background2,
    required this.card,
    required this.accent,
    required this.accentDark,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDim,
    required this.icon,
  });
}
