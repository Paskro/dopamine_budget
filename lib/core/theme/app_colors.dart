import 'package:flutter/material.dart';

abstract final class AppColors {
  // Background
  static const background     = Color(0xFF1A2421);
  static const surface        = Color(0xFF24342F);
  static const surfaceElevated = Color(0xFF2A3D37);

  // Accent
  static const primaryAccent  = Color(0xFF8EB897);
  static const secondaryAccent = Color(0xFFD3A26D);

  // Text
  static const textPrimary    = Color(0xFFF2EFEA);
  static const textSecondary  = Color(0xFFA8B5AF);
  static const textDisabled   = Color(0xFF6E7A75);

  // Icon
  static const iconDefault    = Color(0xFFC8D8CF);
  static const iconActive     = Color(0xFF8EB897);

  // Utility
  static const cardBorder     = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const cardShadow     = Color(0x26103020); // green-tinted, 15%
  static const iconBackground = Color(0x0AFFFFFF); // rgba(255,255,255,0.04)
  static const secondaryBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const ambientGlow    = Color(0x148EB897); // sage green 8%
}