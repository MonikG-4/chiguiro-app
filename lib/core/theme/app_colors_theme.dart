import 'package:flutter/material.dart';

@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  // FONDOS
  final Color firstBackground;        // Cultured / Rich Black → Background (scaffold)
  final Color secondBackground;       // Alice Blue / Dark Gunmetal → Cards
  final Color selectBackground;       // LightSteelBlue → Select / inputs filled

  // TEXTO
  final Color onFirstBackground;      // Texto principal sobre fondo
  final Color secondaryText;          // Slate Gray → Secondary_Letter
  final Color questionText;           // Charcoal Blue (light) / Light Slate Gray (dark) → Question_Letter

  // ACCENTOS/BOTONES
  final Color firstButtonBackground;  // Bright Blue → Primary
  final Color secondButtonBackground; // Cobalt Blue → Secondary
  final Color iconBackground;         // Bright Blue → Acento para íconos/seleccionados

  // BORDES
  final Color border;                 // Light Slate Gray (light) / Charcoal Blue (dark)

  //Secciones
  final Color sectionBg;
  final Color sectionBorder;
  final Color sectionText;

  // ====== Colores globales, no dependen del modo ======
  static const Color focusBorder   = Color(0xFF030303);
  static const Color primary = Color(0xFF006FD1);

  // Indicadores / estados (puedes aplicar .withOpacity() en UI)
  static const Color indicator1    = Color(0xFF57E9B4); // Aquamarine – Indicator
  static const Color indicator2    = Color(0xFFE9A257); // Earth Yellow – Indicator 2

  static const Color infoBackground     = Color(0xFFB3D3EE); // LightSteelBlue
  static const Color successBackground  = Color(0xFF57E9B4);
  static const Color warningBackground  = Color(0xFFE9A257);
  static const Color errorBackground    = Color(0xFFFFF1F2);

  static const Color infoText    = Color(0xFF2563EB);
  static const Color successText = Color(0xFF04763D);
  static const Color warningText = Color(0xFF92400E);
  static const Color errorText       = Color(0xFFEF4444);

  // Gradiente de header (mismo para ambos modos)
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
    required this.sectionBg,
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
      sectionBg: sectionBg ?? this.sectionBg,
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
      sectionBg: Color.lerp(sectionBg, other.sectionBg, t)!,
      sectionBorder: Color.lerp(sectionBorder, other.sectionBorder, t)!,
      sectionText: Color.lerp(sectionText, other.sectionText, t)!,
    );
  }

  // =================== LIGHT (según tus tarjetas) ===================
  static const AppColorScheme light = AppColorScheme(
    firstBackground: Color(0xFFF9FAFC), // Cultured – Background
    secondBackground: Color(0xFFEEF4F8), // Alice Blue – Cards
    selectBackground: Color(0x1A006FD1), // LightSteelBlue – Select

    onFirstBackground: Color(0xFF111827), // texto principal
    secondaryText: Color(0xFF748299),     // Slate Gray – Secondary_Letter
    questionText: Color(0xFF334155),      // Charcoal Blue – Question_Letter

    firstButtonBackground: Color(0xFF006FD1), // Bright Blue – Primary
    secondButtonBackground: Color(0xFF0041A8), // Cobalt Blue – Secundary
    iconBackground: Color(0xFF006FD1), // acento

    border: Color(0xFFCBD5E1), // Light Slate Gray

    sectionBg: Color(0xFFEDE9FE),        // lila claro (background sección)
    sectionBorder: Color(0xFFDDD6FE),    // borde
    sectionText: Color(0xFF1E293B),      // tu primary text

  );

  // =================== DARK (según tus tarjetas) ====================
  static const AppColorScheme dark = AppColorScheme(
    firstBackground: Color(0xFF111827), // Rich Black – Background
    secondBackground: Color(0xFF161D2C), // Dark Gunmetal – Cards
    selectBackground: Color(0x3D006FD1), // LightSteelBlue – Select (mantienes mismo)

    onFirstBackground: Color(0xFFF9FAFC), // texto principal claro
    secondaryText: Color(0xFF748299),     // Slate Gray – Secondary_Letter
    questionText: Color(0xFFCBD5E1),      // Light Slate Gray – Question_Letter

    firstButtonBackground: Color(0xFF006FD1), // Bright Blue – Primary
    secondButtonBackground: Color(0xFF0041A8), // Cobalt Blue – Secundary
    iconBackground: Color(0xFF006FD1),

    border: Color(0xFF334155), // Charcoal Blue

    sectionBg: Color(0xFF241F3D),        // morado petróleo (card de sección)
    sectionBorder: Color(0xFF3C3562),    // borde sutil
    sectionText: Color(0xFFEDE9FE),      // lavanda claro (títulos)
  );
}
