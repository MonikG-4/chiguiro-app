import 'package:flutter/material.dart';

import '../../../core/values/app_colors.dart';
import 'primary_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final String title;
  final String confirmText;
  final String cancelText;

  const ConfirmationDialog({
    super.key,
    required this.message,
    this.title = 'Confirmación',
    this.confirmText = 'Continuar',
    this.cancelText = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        PrimaryButton(
          onPressed: () => Navigator.of(context).pop(false),
          isLoading: false,
          text: cancelText,
          width: 110,
          height: 40,
          textSize: 12,
          backgroundColor: AppColors.cancelButton,
          borderRadius: 6,
        ),
        PrimaryButton(
          onPressed: () => Navigator.of(context).pop(true),
          isLoading: false,
          text: confirmText,
          width: 110,
          height: 40,
          textSize: 12,
          backgroundColor: AppColors.confirmButton,
          borderRadius: 6,
        ),
      ],
    );
  }
}
