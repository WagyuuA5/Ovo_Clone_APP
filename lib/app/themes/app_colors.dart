import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary OVO Purple
  static const Color primary = Color(0xFF4C3494);
  static const Color primaryLight = Color(0xFF6B4FBB);
  static const Color primaryDark = Color(0xFF3A2570);
  static const Color primarySurface = Color(0xFFF3EFFF);

  // Accent
  static const Color accent = Color(0xFFFFD700);

  // Semantic
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFEB5757);
  static const Color warning = Color(0xFFF2994A);
  static const Color info = Color(0xFF2F80ED);

  // Neutral
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B0C0);
  static const Color divider = Color(0xFFEEEEF5);
  static const Color background = Color(0xFFF8F7FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A4C3494);

  // Dark mode specific colors
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textHintDark = Color(0xFF4B5563);
  static const Color dividerDark = Color(0xFF2D2D3F);
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1E1E2F);
  static const Color primarySurfaceDark = Color(0xFF2D1F54);

  // Gradient
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF4C3494), Color(0xFF7B5EA7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF4C3494), Color(0xFF6B4FBB), Color(0xFF7B5EA7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
