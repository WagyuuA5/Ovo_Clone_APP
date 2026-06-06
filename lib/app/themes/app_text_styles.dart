import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.plusJakartaSans();

  // Display
  static TextStyle get displayLarge => _base.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => _base.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  // Headlines
  static TextStyle get headlineLarge => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // Titles
  static TextStyle get titleLarge => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get titleSmall => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  // Body
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  // Labels
  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  // White variants
  static TextStyle get headlineLargeWhite =>
      headlineLarge.copyWith(color: Colors.white);
  static TextStyle get headlineMediumWhite =>
      headlineMedium.copyWith(color: Colors.white);
  static TextStyle get headlineSmallWhite =>
      headlineSmall.copyWith(color: Colors.white);
  static TextStyle get titleLargeWhite =>
      titleLarge.copyWith(color: Colors.white);
  static TextStyle get titleMediumWhite =>
      titleMedium.copyWith(color: Colors.white);
  static TextStyle get titleSmallWhite =>
      titleSmall.copyWith(color: Colors.white);
  static TextStyle get bodyLargeWhite =>
      bodyLarge.copyWith(color: Colors.white);
  static TextStyle get bodyMediumWhite =>
      bodyMedium.copyWith(color: Colors.white);
  static TextStyle get bodySmallWhite =>
      bodySmall.copyWith(color: Colors.white);
  static TextStyle get labelLargeWhite =>
      labelLarge.copyWith(color: Colors.white);
}
