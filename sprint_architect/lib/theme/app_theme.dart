import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sprint Architect Design System
/// Inspired by "Regain" — minimalist, serene, wellness-focused.
class AppTheme {
  // ========== COLORS ==========
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

  // ========== THEME DATA ==========
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepNavy,
      colorScheme: const ColorScheme.dark(
        primary: sageGreen,
        secondary: sageGreenDark,
        surface: cardBackground,
        error: errorRed,
        onPrimary: deepNavy,
        onSecondary: deepNavy,
        onSurface: softWhite,
        onError: softWhite,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: softWhite,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: softWhite,
            letterSpacing: -0.3,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: softWhite,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: softWhite,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: softWhite,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: softWhite,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: lightGray,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: lightGray,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: slateGray,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: sageGreen,
            letterSpacing: 0.5,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: slateGray,
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
          color: softWhite,
        ),
        iconTheme: const IconThemeData(color: softWhite),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sageGreen,
          foregroundColor: deepNavy,
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
          foregroundColor: sageGreen,
          side: const BorderSide(color: sageGreen, width: 1.5),
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
        fillColor: midNavy,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: dividerColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: sageGreen, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: slateGray,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.inter(
          color: lightGray,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkNavy,
        selectedItemColor: sageGreen,
        unselectedItemColor: dimGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBackground,
        contentTextStyle: GoogleFonts.inter(
          color: softWhite,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return sageGreen;
          return dimGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return sageGreenSubtle;
          return lightNavy;
        }),
      ),
    );
  }
}
