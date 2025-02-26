import 'package:flutter/material.dart';
import '../values/app_colors.dart';

class AppTypography {
  static const String defaultFontFamily = 'Poppins';

  static const TextTheme textTheme = TextTheme(
    bodyMedium: TextStyle(
      fontFamily: defaultFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400, // Regular
      color: AppColors.primary,
    ),



  );
}
