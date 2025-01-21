import 'package:flutter/material.dart';

import '../values/app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primary,
      fontFamily: AppTypography.defaultFontFamily,
      textTheme: AppTypography.textTheme,
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: AppColors.secondary),
        hintStyle: TextStyle(color: AppColors.secondary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputs),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.errorInputs),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.errorInputs),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
          borderSide: BorderSide(color: AppColors.inputs),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppTypography.defaultFontFamily,
          ),
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.primaryButton,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: AppTypography.defaultFontFamily,
          ),
          foregroundColor: AppColors.primary,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: AppTypography.defaultFontFamily,
          ),
        ),
      ),
    );
  }
}
