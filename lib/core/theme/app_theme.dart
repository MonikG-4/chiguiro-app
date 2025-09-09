import 'package:flutter/material.dart';
import 'app_colors_theme.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static const String defaultFontFamily = 'Poppins';

  static ThemeData build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = isDark ? AppColorScheme.dark : AppColorScheme.light;

    return ThemeData(
      brightness: brightness,
      fontFamily: defaultFontFamily,
      primaryColor: scheme.iconBackground,
      scaffoldBackgroundColor: scheme.firstBackground,
      extensions: [scheme],
      iconTheme: IconThemeData(color: scheme.onFirstBackground),

      textTheme: AppTypography.textTheme.apply(
        bodyColor: scheme.onFirstBackground,
        displayColor: scheme.onFirstBackground,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.firstBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.onFirstBackground),
        titleTextStyle:  TextStyle(
          color: scheme.onFirstBackground,
          fontFamily: defaultFontFamily,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          // color se hereda de onFirstBackground
        ),
      ),

      cardTheme: CardTheme(
        color: scheme.secondBackground,
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shadowColor: scheme.onFirstBackground.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: scheme.secondaryText),
        hintStyle: TextStyle(color: scheme.secondaryText),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.border),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColorScheme.errorText),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColorScheme.errorText),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(7)),
          borderSide: BorderSide(
            color: isDark ? scheme.iconBackground : AppColorScheme.focusBorder,
          ),
        ),
        filled: true,
        fillColor: scheme.secondBackground, // <- Select
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.firstButtonBackground,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: defaultFontFamily,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.iconBackground,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: defaultFontFamily,
          ),
        ),
      ),
    );
  }
}
