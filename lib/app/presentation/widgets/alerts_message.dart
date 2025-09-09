import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors_theme.dart';

class AlertMessage {
  static const Map<String, Map<String, dynamic>> typeAlert = {
    'Text': {
      'info': AppColorScheme.infoText,
      'success': AppColorScheme.successText,
      'error': AppColorScheme.errorText,
      'warning': AppColorScheme.warningText,
    },
    'Background': {
      'info': AppColorScheme.infoBackground,
      'success': AppColorScheme.successBackground,
      'error': AppColorScheme.errorBackground,
      'warning': AppColorScheme.warningBackground,
    },
    'Icon': {
      'info': Icons.info,
      'success': Icons.check_circle,
      'error': Icons.error,
      'warning': Icons.warning,
    },
  };

  static void showSnackbar({
    required String title,
    required String message,
    required String state,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: typeAlert["Background"]![state].withOpacity(0.8),
      borderRadius: 8,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
      icon: Icon(
        typeAlert["Icon"]![state],
        color: typeAlert["Text"]![state],
        size: 24,
      ),
      titleText: Text(
        title,
        style: TextStyle(
          color: typeAlert["Text"]![state],
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: typeAlert["Text"]![state],
        ),
      ),
    );
  }
}
