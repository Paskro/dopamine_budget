import 'package:flutter/material.dart';

abstract final class AppDims {
  // Spacing (8pt grid)
  static const s1 = 8.0;
  static const s2 = 16.0;
  static const s3 = 24.0;
  static const s4 = 32.0;
  static const s5 = 40.0;
  static const s6 = 48.0;

  // Radius
  static const radiusCard    = 28.0;
  static const radiusButton  = 22.0;
  static const radiusInput   = 24.0;
  static const radiusIcon    = 999.0; // circle

  // Buttons
  static const buttonHeight  = 60.0;

  // Icons
  static const iconContainerSize = 48.0;
  static const iconStroke    = 2.0;

  // Animation
  static const durationShort = Duration(milliseconds: 300);
  static const durationMedium = Duration(milliseconds: 450);
  static const curveMain = Curves.fastOutSlowIn; // fastOutSlowIn
}