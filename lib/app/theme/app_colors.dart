import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background layers
  static const Color background = Color(0xFF08090F);
  static const Color surface = Color(0xFF10141F);
  static const Color surfaceElevated = Color(0xFF171C2C);
  static const Color surfaceHighest = Color(0xFF1E2438);

  // Borders
  static const Color border = Color(0xFF232B3E);
  static const Color borderActive = Color(0xFF3A4560);
  static const Color borderFocus = Color(0xFF00D2FF);

  // Primary accents
  static const Color accentCyan = Color(0xFF00D2FF);
  static const Color accentViolet = Color(0xFF7B61FF);
  static const Color accentGreen = Color(0xFF00FF88);
  static const Color warningAmber = Color(0xFFFFB020);
  static const Color errorRed = Color(0xFFFF4455);

  // Status
  static const Color statusGood = accentGreen;
  static const Color statusWarning = warningAmber;
  static const Color statusError = errorRed;
  static const Color statusSearching = accentCyan;

  // Constellation colors
  static const Color constellationGps = Color(0xFF00D2FF);
  static const Color constellationGlonass = Color(0xFFFF6B6B);
  static const Color constellationGalileo = Color(0xFFFFE455);
  static const Color constellationBeidou = Color(0xFF55FF99);
  static const Color constellationQzss = Color(0xFFFF9F43);
  static const Color constellationSbas = Color(0xFFCC88FF);
  static const Color constellationUnknown = Color(0xFF404F65);

  // Text hierarchy
  static const Color textPrimary = Color(0xFFE4EAF4);
  static const Color textSecondary = Color(0xFF7A8BA0);
  static const Color textTertiary = Color(0xFF404F65);
  static const Color textAccent = accentCyan;
  static const Color textOnAccent = Color(0xFF000000);

  // Shimmer
  static const Color shimmerBase = Color(0xFF1A2035);
  static const Color shimmerHighlight = Color(0xFF242D42);

  // Dividers
  static const Color divider = Color(0xFF1A2035);
}
