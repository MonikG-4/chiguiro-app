import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../../core/theme/app_colors_theme.dart';
import '../../../../controllers/settings_controller.dart';
import '../../../../widgets/confirmation_dialog.dart';
import '../../widgets/body_wrapper.dart';
import '../../widgets/custom_card.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;

    return BodyWrapper(
      child: CustomCard(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOptionTile(
                scheme: scheme,
                icon: Icons.person_outline,
                text: 'Información Personal',
                onTap: controller.goToProfile,
              ),
              _buildOptionTile(
                scheme: scheme,
                icon: Icons.lock_outline,
                text: 'Cambiar contraseña',
                onTap: controller.goToChangePassword,
              ),

              _buildOptionTile(
                scheme: scheme,
                icon: Icons.public,
                text: 'Accesibilidad',
                onTap: controller.goToAccessibility,
              ),
              _buildOptionTile(
                scheme: scheme,
                icon: Icons.shield_outlined,
                text: 'Permisos del dispositivo',
                onTap: controller.goToPermissions,
              ),
              _buildOptionTile(
                scheme: scheme,
                icon: Icons.logout,
                text: 'Cerrar sesión',
                onTap: () async {
                  final confirmed = await Get.dialog<bool>(
                    const ConfirmationDialog(
                      title: 'Cerrar sesión',
                      message: '¿Estás seguro que quieres cerrar sesión?',
                      confirmText: 'Salir',
                    ),
                  );
                  if (confirmed == true) {
                    controller.logout();
                  }
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final version = snapshot.data!.version;
                    return Text(
                      'CHIGÜIRO | Versión $version',
                      style: TextStyle(color: scheme.secondaryText, fontSize: 12),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required AppColorScheme scheme,
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
            color: scheme.firstBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.border.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: scheme.secondaryText),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 15, color: scheme.secondaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
