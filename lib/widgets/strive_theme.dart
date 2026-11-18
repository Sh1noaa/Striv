import 'package:flutter/material.dart';

class StriveColors {
  // Primary Duolingo-Evolved Palette
  static const Color emerald = Color(0xFF58CC02);
  static const Color emeraldLip = Color(0xFF46A302);
  static const Color emeraldSoft = Color(0x1F58CC02);

  static const Color amber = Color(0xFFFF9600);
  static const Color amberLip = Color(0xFFD67E00);

  static const Color rose = Color(0xFFFF4B4B);
  static const Color roseLip = Color(0xFFD33131);

  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoLip = Color(0xFF4338CA);

  static const Color sky = Color(0xFF1CB0F6);
  static const Color skyLip = Color(0xFF1899D6);

  static const Color purple = Color(0xFFA855F7);
  static const Color purpleLip = Color(0xFF7E22CE);

  // Dark Slate Palette
  static const Color darkBg = Color(0xFF0B1320);
  static const Color darkSurface = Color(0xFF152033);
  static const Color darkCard = Color(0xFF1C2A42);
  static const Color darkBorder = Color(0xFF2D4060);
  static const Color darkLip = Color(0xFF0E1726);

  // Crisp Light Palette
  static const Color lightBg = Color(0xFFF5F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFDCE4F0);
  static const Color lightLip = Color(0xFFC5D2E6);

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkCard
          : lightCard;

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBg
          : lightBg;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBorder
          : lightBorder;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFF8FAFC)
          : const Color(0xFF1E293B);

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF94A3B8)
          : const Color(0xFF64748B);
}

class StriveTheme {
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: StriveColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: StriveColors.emerald,
        secondary: StriveColors.amber,
        tertiary: StriveColors.indigo,
        surface: StriveColors.darkSurface,
        error: StriveColors.rose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: StriveColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: StriveColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: StriveColors.darkBorder, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StriveColors.darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StriveColors.darkBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StriveColors.darkBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StriveColors.emerald, width: 2.5),
        ),
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: StriveColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: StriveColors.emerald,
        secondary: StriveColors.amber,
        tertiary: StriveColors.indigo,
        surface: StriveColors.lightSurface,
        error: StriveColors.rose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: StriveColors.lightSurface,
        foregroundColor: Color(0xFF1E293B),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: StriveColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: StriveColors.lightBorder, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: StriveColors.lightBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: StriveColors.lightBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StriveColors.emerald, width: 2.5),
        ),
      ),
    );
  }
}
