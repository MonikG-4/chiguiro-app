import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../widgets/confirmation_dialog.dart';
import '../../../../../../widgets/primary_button.dart';

class PermissionDetailPage extends StatelessWidget {
  final String title;
  final bool isGranted;
  final String allowedTitle;
  final String allowedDescription;
  final String deniedTitle;
  final String deniedDescription;
  final VoidCallback onOpenSettings;

  const PermissionDetailPage({
    super.key,
    required this.title,
    required this.isGranted,
    required this.allowedTitle,
    required this.allowedDescription,
    required this.deniedTitle,
    required this.deniedDescription,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final currentTitle = isGranted ? allowedTitle : deniedTitle;
    final currentDescription =
    isGranted ? allowedDescription : deniedDescription;
    final otherTitle = isGranted ? deniedTitle : allowedTitle;
    final otherDescription = isGranted ? deniedDescription : allowedDescription;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          tooltip: 'Volver',
          onPressed: Get.back,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Tu dispositivo está configurado en:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),

          _PermissionOption(
            title: currentTitle,
            description: currentDescription,
            selected: true,
          ),

          const SizedBox(height: 24),
          const Text('Otra opción', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),

          _PermissionOption(
            title: otherTitle,
            description: otherDescription,
            selected: false,
          ),

          const SizedBox(height: 20),
          const Text(
            'Para actualizar los permisos, ve a la configuración del dispositivo.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewPadding.bottom + 32,
          left: 24,
          right: 24,
        ),
        child: PrimaryButton(
          isLoading: false,
          onPressed: () async {
            final confirmed = await Get.dialog<bool>(
              ConfirmationDialog(
                title: 'Actualizar configuración del dispositivo',
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Abre la configuración de tu dispositivo, toca “Permisos” y elige cómo quieres permitir el acceso.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrimaryButton(
                          isLoading: false,
                          onPressed: () => Get.back(result: true),
                          text: 'Abrir configuración',
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('Ahora no'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
            if (confirmed == true) onOpenSettings();
          },
          text: 'Abrir configuración',
        ),
      ),
    );
  }
}

class _PermissionOption extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;

  const _PermissionOption({
    required this.title,
    required this.description,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return Card(
      elevation: selected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
        selected
            ? BorderSide(color: scheme.firstButtonBackground, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: selected ? 18 : 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
