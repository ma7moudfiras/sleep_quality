import 'package:flutter/material.dart';

class AppTheme {
  static const Color midnight = Color(0xFF0F172A);
  static const Color indigo = Color(0xFF4F46E5);
  static const Color violet = Color(0xFF7C3AED);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color surface = Color(0xFFF6F8FC);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: indigo,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarThemeData(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: midnight,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.07)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: indigo, width: 1.6),
        ),
      ),
      cardTheme: CardThemeData(

        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(color: indigo.withValues(alpha: 0.22)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          foregroundColor: midnight,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        backgroundColor: Colors.white,
        selectedColor: scheme.primaryContainer,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.94),
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? midnight : Colors.black54,
          );
        }),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 7,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        activeTrackColor: indigo,
        inactiveTrackColor: indigo.withValues(alpha: 0.14),
      ),
    );
  }
}
