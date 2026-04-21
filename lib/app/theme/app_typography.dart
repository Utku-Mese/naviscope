import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String _monoFamily = 'JetBrainsMono';
  static const String _sansFamily = 'Inter';

  // Hero data values — lat/lon/altitude
  static const TextStyle heroValue = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 40,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.1,
  );

  // Primary metric values
  static const TextStyle primaryValue = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Secondary metric values
  static const TextStyle secondaryValue = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Dense table / list values
  static const TextStyle denseValue = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Small mono for badges, SVIDs
  static const TextStyle monoSmall = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Field labels — uppercase, spaced
  static const TextStyle fieldLabel = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 1.4,
    height: 1.4,
  );

  // Body text
  static const TextStyle body = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Body secondary
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  // Status / badge text
  static const TextStyle badge = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.2,
  );

  // Section header
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.2,
    height: 1.4,
  );

  // Screen title
  static const TextStyle screenTitle = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Unit suffix (inline with value)
  static const TextStyle unit = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.2,
  );
}
