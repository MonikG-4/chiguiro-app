import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';

class AlertMessage {
  static const Map<String, Map<String, dynamic>> typeAlert = {
    'Text': {
      'success': AppColors.successText,
      'error': AppColors.errorText,
      'warning': AppColors.warningText,
    },
    'Background': {
      'success': AppColors.successBackground,
      'error': AppColors.errorBackground,
      'warning': AppColors.warningBackground,
    },
    'Icon': {
      'success': Icons.check_circle,
      'error': Icons.error,
      'warning': Icons.warning,
    },
  };

  static void showSnackbar({
    required String message,
    required String state,
  }) {
    Get.snackbar(
      '',
      message,
      backgroundColor: typeAlert["Background"]![state],
      borderRadius: 8,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDismissible: true,
      titleText: const SizedBox.shrink(),
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
      icon: Icon(
        typeAlert["Icon"]![state],
        color: typeAlert["Text"]![state],
        size: 24,
      ),
      messageText: Text(
        message,
        style: TextStyle(
          color: typeAlert["Text"]![state],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
