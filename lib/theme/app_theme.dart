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
  // Palettes Map
  static const Map<String, PaletteColors> palettes = {
    'Obsidian Mint': PaletteColors(
      background: Color(0xFF0C0E12),
      surface: Color(0xFF161A22),
      surfaceLight: Color(0xFF222834),
      primary: Color(0xFF00E676), // Vibrant Mint
      accent: Color(0xFF26A69A), // Cyan/Teal
      cardGradient: [Color(0xFF00E676), Color(0xFF00B0FF)],
    ),
    'Sunset Rose': PaletteColors(
      background: Color(0xFF0F0B13),
      surface: Color(0xFF191322),
      surfaceLight: Color(0xFF251C33),
      primary: Color(0xFFFF4081), // Deep Pink
      accent: Color(0xFFFF7043), // Sunset Orange
      cardGradient: [Color(0xFFFF4081), Color(0xFFFFAB40)],
    ),
    'Cyberpunk Neon': PaletteColors(
      background: Color(0xFF050505),
      surface: Color(0xFF121216),
      surfaceLight: Color(0xFF1C1C24),
      primary: Color(0xFF00E5FF), // Electric Neon Cyan
      accent: Color(0xFFE040FB), // Neon Purple
      cardGradient: [Color(0xFF00E5FF), Color(0xFFE040FB)],
    ),
    'Deep Sapphire': PaletteColors(
      background: Color(0xFF080D1A),
      surface: Color(0xFF121B2D),
      surfaceLight: Color(0xFF1D2A45),
      primary: Color(0xFF29B6F6), // Sapphire Sky
      accent: Color(0xFFAB47BC), // Lavender Purple
      cardGradient: [Color(0xFF29B6F6), Color(0xFF7E57C2)],
    ),
  };

  static PaletteColors getColors(String paletteName) {
    return palettes[paletteName] ?? palettes['Obsidian Mint']!;
  }

  // Light Mode Colors (Fallback/Alternative)
  static const PaletteColors lightPalette = PaletteColors(
    background: Color(0xFFF5F7FA),
    surface: Colors.white,
    surfaceLight: Color(0xFFEFEFF4),
    primary: Color(0xFF00D179),
    accent: Color(0xFF00B0FF),
    cardGradient: [Color(0xFF00D179), Color(0xFF00B0FF)],
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
