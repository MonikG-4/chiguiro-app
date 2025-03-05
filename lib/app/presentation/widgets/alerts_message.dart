import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';

class AlertMessage {
  static const Map<String, Map<String, dynamic>> typeAlert = {
    'Text': {
      'info': AppColors.infoText,
      'success': AppColors.successText,
      'error': AppColors.errorText,
      'warning': AppColors.warningText,
    },
    'Background': {
      'info': AppColors.infoBackground,
      'success': AppColors.successBackground,
      'error': AppColors.errorBackground,
      'warning': AppColors.warningBackground,
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
