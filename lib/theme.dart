import 'dart:ui';

import 'package:flutter/cupertino.dart';

class CustomTheme {
  const CustomTheme();

  // Colores principales de EasySave: Verde, Morado y Blanco
  static const Color primaryGreen = Color(0xFF2ECC71); // Verde principal
  static const Color primaryPurple = Color(0xFF9B59B6); // Morado principal
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF666666);

  // Gradientes para EasySave
  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[primaryGreen, primaryPurple],
    stops: <double>[0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient reverseGradient = LinearGradient(
    colors: <Color>[primaryPurple, primaryGreen],
    stops: <double>[0.0, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
