import 'package:flutter/material.dart';
import '../../models/air_quality_status.dart';

class AM032Colors {
  static const Color bgPrimary = Color(0xFF0A0E1A);
  static const Color bgSurface = Color(0xFF111827);
  static const Color bgElevated = Color(0xFF1C2333);

  static const Color statusGood = Color(0xFF22C55E);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusDanger  = Color(0xFFEF4444);
  static const Color statusOffline = Color(0xFF6B7280);

  static const Color glowGood    = Color(0x5522C55E);
  static const Color glowWarning = Color(0x55F59E0B);
  static const Color glowDanger  = Color(0x55EF4444);
 
  static const Color accentBlue  = Color(0xFF3B82F6);
  static const Color accentCyan  = Color(0xFF06B6D4);
 
  static const Color textPrimary   = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted     = Color(0xFF6B7280);
 
  static const Color border       = Color(0xFF1F2937);
  static const Color borderActive = Color(0xFF374151);
}

class AM032Theme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AM032Colors.bgPrimary,
    colorScheme: const ColorScheme.dark(
      surface: AM032Colors.bgSurface,
      primary: AM032Colors.accentBlue,
      secondary: AM032Colors.accentCyan,
      error: AM032Colors.statusDanger,
    ),

    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AM032Colors.bgPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AM032Colors.textPrimary,
      ),
    ),

    cardTheme: CardThemeData(
      color: AM032Colors.bgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AM032Colors.border)
      )
    )
  );

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Inter', fontSize: 48, fontWeight: FontWeight.w800,
      color: AM032Colors.textPrimary, letterSpacing: -1.5,
    ),

    displayMedium: TextStyle(
      fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w700,
      color: AM032Colors.textPrimary, letterSpacing: -1.0,
    ),

    titleLarge: TextStyle(
      fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600,
      color: AM032Colors.textPrimary,
    ),

    bodyLarge: TextStyle(
      fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w400,
      color: AM032Colors.textPrimary,
    ),

    bodyMedium: TextStyle(
      fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w400,
      color: AM032Colors.textSecondary
    ),

    labelSmall: TextStyle(
      fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600,
      color: AM032Colors.textMuted, letterSpacing: 1.2,
    ),
  );
}

extension AirQualityStateColors on AirQualityState {
  Color get color {
    switch (this) {
      case AirQualityState.good: return AM032Colors.statusGood;
      case AirQualityState.warning: return AM032Colors.statusWarning;
      case AirQualityState.danger: return AM032Colors.statusDanger;
    }
  }

  Color get glowColor {
    switch (this) {
      case AirQualityState.good: return AM032Colors.glowGood;
      case AirQualityState.warning: return AM032Colors.glowWarning;
      case AirQualityState.danger: return AM032Colors.glowDanger;

    }
  }
}