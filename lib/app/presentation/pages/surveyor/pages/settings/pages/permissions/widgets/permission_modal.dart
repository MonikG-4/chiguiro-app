import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../../core/theme/app_colors_theme.dart';

class PermissionModal extends StatelessWidget {
  const PermissionModal({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: scheme.firstBackground,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Actualizar configuración del dispositivo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Abre la configuración de tu dispositivo, toca “Permisos” y elige cómo quieres permitir el acceso.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorScheme.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text('Abrir configuración'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text(
                    'Ahora no',
                    style: TextStyle(color: AppColorScheme.primary),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

