import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/permission_modal.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu dispositivo está configurado en',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Opción activa (primera)
            _buildOption(
              title: isGranted ? allowedTitle : deniedTitle,
              description: isGranted ? allowedDescription : deniedDescription,
              selected: true,
            ),

            const SizedBox(height: 24),
            const Text('Otra opción', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),

            // Opción inactiva (segunda)
            _buildOption(
              title: isGranted ? deniedTitle : allowedTitle,
              description: isGranted ? deniedDescription : allowedDescription,
              selected: false,
            ),
            const SizedBox(height: 12),
            const Text(
              'Para actualizar los permisos, '
                  've a la configuración del dispositivo.',
              style: TextStyle(color: Colors.grey),
            ),
            const Spacer(),

            ElevatedButton(
              onPressed: () async {
                final confirmed = await Get.dialog<bool>(
                  const PermissionModal(),
                );
                if (confirmed == true) onOpenSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF189F8E),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Actualizar configuración del dispositivo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required String description,
    required bool selected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
