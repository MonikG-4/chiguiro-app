import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../controllers/theme_controller.dart';
import '../../../../../../../widgets/confirmation_dialog.dart';

class ThemeModeSettingItem extends StatelessWidget {

  const ThemeModeSettingItem({super.key});

  void _showThemeModal(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    ThemeMode tempMode =  themeController.themeMode.value;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmationDialog(
        title: 'Escoge un tema',
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: ThemeMode.values.map((mode) {
                return RadioListTile<ThemeMode>(
                  title: Text(_getModeLabel(mode)),
                  value: mode,
                  groupValue: tempMode,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => tempMode = value);
                    }
                  },
                );
              }).toList(),
            );
          },
        ),
        confirmText: 'Guardar',
        onConfirm: () {
          themeController.toggleTheme(tempMode);
          Get.back();
        },
        onCancel: () => Get.back(),
      ),
    );
  }

  String _getModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Predeterminado';
      case ThemeMode.light:
        return 'Modo Claro';
      case ThemeMode.dark:
        return 'Modo Oscuro';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.contrast),
      title: const Text(
        'Tema',
      ),
      onTap: () => _showThemeModal(context),
    );
  }
}
