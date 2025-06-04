import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../controllers/settings_controller.dart';
import '../../widgets/body_wrapper.dart';
import '../../widgets/custom_card.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BodyWrapper(
      child: CustomCard(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOptionTile(
                icon: Icons.person_outline,
                text: 'Información Personal',
                onTap: controller.goToProfile,
              ),
              _buildOptionTile(
                icon: Icons.lock_outline,
                text: 'Cambiar contraseña',
                onTap: controller.goToChangePassword,
              ),
              _buildOptionTile(
                icon: Icons.shield_outlined,
                text: 'Permisos del dispositivo',
                onTap: controller.goToPermissions,
              ),
              _buildOptionTile(
                icon: Icons.logout,
                text: 'Cerrar sesión',
                onTap: controller.logout,
              ),
              const SizedBox(height: 32),
              Center(
                child: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final version = snapshot.data!.version;
                    return Text(
                      'CHIGÜIRO | Versión $version',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    );
                  },
                ),
              )

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
