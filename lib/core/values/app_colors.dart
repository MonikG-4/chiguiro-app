import 'package:flutter/material.dart';

class AppColors {
  //Texto
  static const Color primary = Color(0xFF1E293B);
  static const Color secondary = Color(0xFF748299);
  static const Color tertiary = Color(0xFF0D9488);

  static const Color successText = Color(0xFF04763D);
  static const Color warningText = Color(0xFF92400E);
  static const Color errorText = Color(0xFFB91C1C);

  //Boton
  static const Color primaryButton = Color(0xFF0D9488);

  //Fondo
  static const Color background = Color(0xFFEEF4F8);
  static const LinearGradient backgroundSecondary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E293B), // Inicio del gradiente
      Color(0xFF5270A1), // Fin del gradiente
    ],
  );

  static const Color successBackground = Color(0xFFEDFCF3);
  static const Color warningBackground = Color(0xFFFFF4E5);
  static const Color errorBackground = Color(0xFFFFF1F2);

  //Borde
  static const Color inputs = Color(0xFF748299);
  static const Color errorInputs = Color(0xFFB91C1C);

  static const Color successBorder = Color(0xFF26D87B);
  static const Color warningBorder = Color(0xFFFACC15);
  static const Color errorBorder = Color(0xFFEF4444);


  //Preguntas
  static const Color progressBar = Color(0xFF57E9B4);
  static const Color star = Color(0xFFF8B84E);
  static const Color scale = Color(0xFFBEF6E1 );
}
