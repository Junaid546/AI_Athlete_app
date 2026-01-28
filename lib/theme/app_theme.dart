import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Based on UI Design Specifications
  static const Color primaryStart = Color(0xFF6366F1); // Indigo
  static const Color primaryEnd = Color(0xFF8B5CF6); // Purple
  static const Color primaryColor = primaryStart;
  static const Color secondaryColor = Color(0xFF10B981); // Emerald (Success)
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color dangerColor = Color(0xFFEF4444); // Red
  static const Color accentColor = warningColor; // For alerts/PRs

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F0F0F); // True Black
  static const Color darkSurface = Color(0xFF1A1A1A); // Card BG
  static const Color darkSurfaceElevated = Color(0xFF262626);
  static const Color darkBorder = Color(0xFF333333);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF9FAFB);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Gradients - Based on UI Design
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [secondaryColor, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography - Based on UI Design Scale
  static TextTheme _getTextTheme({required bool isDark}) {
    final textColor = isDark ? Colors.white : Colors.black;
    final bodyColor = isDark ? Colors.white70 : Colors.black87;
    final captionColor = isDark ? Colors.white60 : Colors.black54;

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: bodyColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: bodyColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: captionColor,
      ),
      labelLarge: GoogleFonts.robotoMono(
        fontSize: 14,
        color: textColor,
      ),
      labelMedium: GoogleFonts.robotoMono(
        fontSize: 12,
        color: textColor,
      ),
      labelSmall: GoogleFonts.robotoMono(
        fontSize: 10,
        color: textColor,
      ),
    );
  }

  static TextTheme get textTheme => _getTextTheme(isDark: true); // Backward compatibility

  // Light Theme - Based on UI Design
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      background: lightBackground,
      surface: lightSurface,
      onBackground: Colors.black,
      onSurface: Colors.black,
      primary: primaryColor,
      secondary: secondaryColor,
      error: dangerColor,
    ),
    scaffoldBackgroundColor: lightBackground,
    textTheme: _getTextTheme(isDark: false),
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: primaryColor.withOpacity(0.2),
        elevation: 4,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );

  // Dark Theme - Based on UI Design
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      background: darkBackground,
      surface: darkSurface,
      onBackground: Colors.white,
      onSurface: Colors.white,
      primary: primaryColor,
      secondary: secondaryColor,
      error: dangerColor,
    ),
    scaffoldBackgroundColor: darkBackground,
    textTheme: _getTextTheme(isDark: true),
    cardTheme: CardThemeData(
      elevation: 0,
      color: darkSurface,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: primaryColor.withOpacity(0.3),
        elevation: 8,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );

  // Glassmorphism Card
  static Widget glassmorphismCard({
    required Widget child,
    double blur = 10,
    double opacity = 0.1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(opacity * 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blur,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: child,
        ),
      ),
    );
  }

  // Neumorphic Button
  static Widget neumorphicButton({
    required Widget child,
    required VoidCallback onPressed,
    double depth = 4,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(depth, depth),
              blurRadius: depth * 2,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              offset: Offset(-depth, -depth),
              blurRadius: depth * 2,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
