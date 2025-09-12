import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../controllers/text_scale_controller.dart';
import '../../../../../../../widgets/confirmation_dialog.dart';


class TextScaleSelector extends StatelessWidget {
  const TextScaleSelector({super.key});

  void _showTextScaleModal(BuildContext context) {
    final controller = Get.find<TextScaleController>();
    AppTextScale tempScale = controller.textScale.value;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmationDialog(
        title: 'Escoge un tamaño de fuente',
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: AppTextScale.values.map((scale) {
                final label = switch (scale) {
                  AppTextScale.normal => 'Predeterminado',
                  AppTextScale.small => 'Pequeño',
                  AppTextScale.large => 'Grande',
                };

                return RadioListTile<AppTextScale>(
                  title: Text(label),
                  value: scale,
                  groupValue: tempScale,
                  onChanged: (value) => setState(() => tempScale = value!),
                );
              }).toList(),
            );
          },
        ),
        confirmText: 'Guardar',
        onConfirm: () {
          controller.updateScale(tempScale);
          Get.back();
        },
        onCancel: () => Get.back(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.format_size),
      title: const Text(
        'Tamaño de fuente',
      ),
      onTap: () => _showTextScaleModal(context),
    );
  }
}
