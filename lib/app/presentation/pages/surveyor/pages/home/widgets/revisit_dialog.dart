import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../../../../core/values/app_colors.dart';
import '../../../../../widgets/primary_button.dart';

class RevisitDialog extends StatefulWidget {
  final String message;
  final String title;
  final String confirmText;
  final String cancelText;

  const RevisitDialog({
    super.key,
    required this.message,
    this.title = 'Confirmación',
    this.confirmText = 'Continuar',
    this.cancelText = 'Cancelar',
  });

  @override
  State<RevisitDialog> createState() => _RevisitDialogState();
}

class _RevisitDialogState extends State<RevisitDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.message,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            minLines: 3,
            maxLines: 3,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Ejemplo: No estaban todos los integrantes',
              filled: true,
              fillColor: Color(0xFFECE6F0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
      actions: [
        PrimaryButton(
          onPressed: () => Get.back(result: null),
          backgroundColor: AppColors.cancelButton,
          height: 40,
          width: 110,
          textSize: 13,
          borderRadius: 8,
          isLoading: false,
          child: widget.cancelText,
        ),
        PrimaryButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            if (reason.isNotEmpty) {
              Get.back(result: reason);
            }
          },
          backgroundColor: AppColors.confirmButton,
          height: 40,
          width: 120,
          textSize: 13,
          borderRadius: 8,
          isLoading: false,
          child: widget.confirmText,
        ),
      ],
    );
  }
}
