import 'package:flutter/material.dart';

class PaletteColors {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color primary;
  final Color accent;
  final List<Color> cardGradient;

  const PaletteColors({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.primary,
    required this.accent,
    required this.cardGradient,
  });
}

class AppTheme {
  // Single premium blue dark mode palette colors
  static const PaletteColors blueColors = PaletteColors(
    background: Color(0xFF0A0F1D), // Elegant dark sapphire
    surface: Color(0xFF131A2E),    // Slate sapphire card
    surfaceLight: Color(0xFF1E294B),
    primary: Color(0xFF3B82F6),    // Vibrant blue
    accent: Color(0xFF60A5FA),     // Accent sky blue
    cardGradient: [Color(0xFF2563EB), Color(0xFF60A5FA)],
  );

  static const Map<String, PaletteColors> palettes = {
    'Deep Sapphire': blueColors,
  };

  static PaletteColors getColors(String paletteName) {
    return blueColors;
  }

  // Light Mode Colors (Unified Blue)
  static const PaletteColors lightPalette = PaletteColors(
    background: Color(0xFFF8FAFC),
    surface: Colors.white,
    surfaceLight: Color(0xFFF1F5F9),
    primary: Color(0xFF2563EB), // Blue 600
    accent: Color(0xFF3B82F6),
    cardGradient: [Color(0xFF2563EB), Color(0xFF3B82F6)],
  );

  static ThemeData buildTheme(
    BuildContext context,
    String paletteName,
    ThemeMode mode,
  ) {
    final bool isDark = mode == ThemeMode.dark;
    final PaletteColors colors = isDark ? getColors(paletteName) : lightPalette;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primary,
      cardColor: colors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
        elevation: 10,
      ),
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: colors.primary,
              secondary: colors.accent,
              surface: colors.surface,
            )
          : ColorScheme.light(
              primary: colors.primary,
              secondary: colors.accent,
              surface: colors.surface,
            ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w800,
          fontSize: 32,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      dialogTheme: DialogThemeData(backgroundColor: colors.surface),
    );
  }

  // Premium Box Shadow
  static BoxShadow get premiumShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.2),
    blurRadius: 16,
    spreadRadius: -4,
    offset: const Offset(0, 8),
  );

  // Soft Glassy Border
  static Border get glassBorder =>
      Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.2);

  static LinearGradient getGradient(Color color) {
    return LinearGradient(
      colors: [color, color.withValues(alpha: 0.75)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
