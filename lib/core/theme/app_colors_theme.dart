import 'package:flutter/material.dart';

@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  // FONDOS
  final Color firstBackground;
  final Color secondBackground;
  final Color selectBackground;

  // TEXTO
  final Color onFirstBackground;
  final Color secondaryText;
  final Color questionText;

  // ACCENTOS/BOTONES
  final Color firstButtonBackground;
  final Color secondButtonBackground;
  final Color iconBackground;

  // BORDES
  final Color border;

  //Secciones
  final Color sectionBackground;
  final Color sectionBorder;
  final Color sectionText;

  // ====== Colores globales, no dependen del tema ======
  static const Color focusBorder   = Color(0xFF030303);
  static const Color primary = Color(0xFF006FD1);

  // Indicadores
  static const Color indicator1    = Color(0xFF57E9B4);
  static const Color indicator2    = Color(0xFFE9A257);

  static const Color infoBackground     = Color(0xFFB3D3EE);
  static const Color successBackground  = Color(0xFF57E9B4);
  static const Color warningBackground  = Color(0xFFE9A257);
  static const Color errorBackground    = Color(0xFFFFF1F2);

  static const Color infoText    = Color(0xFF2563EB);
  static const Color successText = Color(0xFF04763D);
  static const Color warningText = Color(0xFF92400E);
  static const Color errorText       = Color(0xFFEF4444);

  // Gradiente de header
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E293B), Color(0xFF104883)],
  );

  const AppColorScheme({
    required this.firstBackground,
    required this.onFirstBackground,
    required this.secondBackground,
    required this.selectBackground,
    required this.firstButtonBackground,
    required this.secondButtonBackground,
    required this.iconBackground,
    required this.border,
    required this.secondaryText,
    required this.questionText,
    required this.sectionBackground,
    required this.sectionBorder,
    required this.sectionText,
  });

  @override
  AppColorScheme copyWith({
    Color? firstBackground,
    Color? onFirstBackground,
    Color? secondBackground,
    Color? selectBackground,
    Color? firstButtonBackground,
    Color? secondButtonBackground,
    Color? iconBackground,
    Color? border,
    Color? secondaryText,
    Color? questionText,
    Color? sectionBg,
    Color? sectionBorder,
    Color? sectionText,
  }) {
    return AppColorScheme(
      firstBackground: firstBackground ?? this.firstBackground,
      onFirstBackground: onFirstBackground ?? this.onFirstBackground,
      secondBackground: secondBackground ?? this.secondBackground,
      selectBackground: selectBackground ?? this.selectBackground,
      firstButtonBackground: firstButtonBackground ?? this.firstButtonBackground,
      secondButtonBackground: secondButtonBackground ?? this.secondButtonBackground,
      iconBackground: iconBackground ?? this.iconBackground,
      border: border ?? this.border,
      secondaryText: secondaryText ?? this.secondaryText,
      questionText: questionText ?? this.questionText,
      sectionBackground: sectionBg ?? this.sectionBackground,
      sectionBorder: sectionBorder ?? this.sectionBorder,
      sectionText: sectionText ?? this.sectionText,
    );
  }

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      firstBackground: Color.lerp(firstBackground, other.firstBackground, t)!,
      onFirstBackground: Color.lerp(onFirstBackground, other.onFirstBackground, t)!,
      secondBackground: Color.lerp(secondBackground, other.secondBackground, t)!,
      selectBackground: Color.lerp(selectBackground, other.selectBackground, t)!,
      firstButtonBackground: Color.lerp(firstButtonBackground, other.firstButtonBackground, t)!,
      secondButtonBackground: Color.lerp(secondButtonBackground, other.secondButtonBackground, t)!,
      iconBackground: Color.lerp(iconBackground, other.iconBackground, t)!,
      border: Color.lerp(border, other.border, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      questionText: Color.lerp(questionText, other.questionText, t)!,
      sectionBackground: Color.lerp(sectionBackground, other.sectionBackground, t)!,
      sectionBorder: Color.lerp(sectionBorder, other.sectionBorder, t)!,
      sectionText: Color.lerp(sectionText, other.sectionText, t)!,
    );
  }

  // =================== LIGHT  ===================
  static const AppColorScheme light = AppColorScheme(
    firstBackground: Color(0xFFF9FAFC),
    secondBackground: Color(0xFFEEF4F8),
    selectBackground: Color(0x1A006FD1),

    onFirstBackground: Color(0xFF111827),
    secondaryText: Color(0xFF748299),
    questionText: Color(0xFF334155),

    firstButtonBackground: Color(0xFF006FD1),
    secondButtonBackground: Color(0xFF0041A8),
    iconBackground: Color(0xFF006FD1),

    border: Color(0xFFCBD5E1), // Light Slate Gray

    sectionBackground: Color(0xFFE7DFC6),
    sectionBorder: Color(0xFFDDD6FE),
    sectionText: Color(0xFF1E293B),

  );

  // =================== DARK  ====================
  static const AppColorScheme dark = AppColorScheme(
    firstBackground: Color(0xFF111827),
    secondBackground: Color(0xFF161D2C),
    selectBackground: Color(0x3D006FD1),

    onFirstBackground: Color(0xFFF9FAFC),
    secondaryText: Color(0xFF748299),
    questionText: Color(0xFFCBD5E1),

    firstButtonBackground: Color(0xFF006FD1),
    secondButtonBackground: Color(0xFF0041A8),
    iconBackground: Color(0xFF006FD1),

    border: Color(0xFF475569),

    sectionBackground: Color(0xFF816C61),
    sectionBorder: Color(0xFFFE7D0B),
    sectionText: Color(0xFFEDE9FE),
  );
}
