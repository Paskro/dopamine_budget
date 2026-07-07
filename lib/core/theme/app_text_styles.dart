import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const _base = TextStyle(
    fontFamily: 'Manrope',
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static const h1    = TextStyle(fontFamily: 'Manrope', fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.35);
  static const h2    = TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.35);
  static const title = TextStyle(fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.35);
  static const body  = TextStyle(fontFamily: 'Manrope', fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.35);
  static const caption = TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.35);
}