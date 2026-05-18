import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  static final List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.04),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.06),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
  ];

  static final List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.08),
      blurRadius: 34,
      offset: const Offset(0, 18),
    ),
  ];

  static final List<BoxShadow> up = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.08),
      blurRadius: 22,
      offset: const Offset(0, -8),
    ),
  ];
}
