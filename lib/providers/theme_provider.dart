import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import 'settings_provider.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  final Ref ref;

  ThemeNotifier(this.ref) : super(_createThemeData(ref.read(settingsProvider))) {
    // Listen to settings changes
    ref.listen<AppSettings>(settingsProvider, (previous, next) {
      state = _createThemeData(next);
    });
  }

  static ThemeData _createThemeData(AppSettings settings) {
    final accentColor = settings.getAccentColor();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: _getBrightness(settings.themeMode),
      ),
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontFamily: 'Poppins', fontSize: 32 * settings.fontSize, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontFamily: 'Poppins', fontSize: 28 * settings.fontSize, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontFamily: 'Poppins', fontSize: 24 * settings.fontSize, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontFamily: 'Poppins', fontSize: 22 * settings.fontSize, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontFamily: 'Poppins', fontSize: 20 * settings.fontSize, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontFamily: 'Poppins', fontSize: 18 * settings.fontSize, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 16 * settings.fontSize, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 14 * settings.fontSize, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 12 * settings.fontSize, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16 * settings.fontSize),
        bodyMedium: TextStyle(fontSize: 14 * settings.fontSize),
        bodySmall: TextStyle(fontSize: 12 * settings.fontSize),
        labelLarge: TextStyle(fontSize: 14 * settings.fontSize, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12 * settings.fontSize, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 11 * settings.fontSize, fontWeight: FontWeight.w500),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _getBrightness(settings.themeMode) == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        foregroundColor: _getBrightness(settings.themeMode) == Brightness.dark
            ? Colors.white
            : Colors.black,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20 * settings.fontSize,
          fontWeight: FontWeight.w600,
          color: _getBrightness(settings.themeMode) == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: TextStyle(
            fontSize: 16 * settings.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _getBrightness(settings.themeMode) == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor.withOpacity(0.3);
          }
          return null;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentColor,
        inactiveTrackColor: accentColor.withOpacity(0.3),
        thumbColor: accentColor,
        overlayColor: accentColor.withOpacity(0.2),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accentColor,
        unselectedLabelColor: _getBrightness(settings.themeMode) == Brightness.dark
            ? Colors.white70
            : Colors.black54,
        indicatorColor: accentColor,
        labelStyle: TextStyle(
          fontSize: 16 * settings.fontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16 * settings.fontSize,
        ),
      ),
    );
  }

  static Brightness _getBrightness(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier(ref);
});
