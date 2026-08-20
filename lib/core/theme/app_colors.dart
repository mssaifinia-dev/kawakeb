import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color gold = Color(0xFFFFD700);
  static const Color purple = Color(0xFF6B2DD9);
  static const Color darkPurple = Color(0xFF2B0D3A);
  static const Color black = Color(0xFF0D0D0D);

  static const Color background = black;
  static const Color surface = darkPurple;

  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF12061C), darkPurple, black],
  );

  static const LinearGradient secondaryButtonGradient = LinearGradient(
    colors: [Color(0xFF8B4FE0), purple],
  );

  static const Color textPrimary = Color(0xFFF5F0FA);
  static const Color textSecondary = Color(0xFFB9A8CC);

  static const Color textOnGold = black;
  static const Color textOnPurple = Colors.white;
  static const Color buttonDisabled = Color(0xFF2A2430);
  static const Color textDisabled = Color(0xFF5C5266);

  static const Color glassFill = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFD700);
  static const Color borderGold = Color(0x55FFD700);

  static const Color starColor = Color(0xFFFFF6D5);
  static const Color error = Color(0xFFE0507A);
}
