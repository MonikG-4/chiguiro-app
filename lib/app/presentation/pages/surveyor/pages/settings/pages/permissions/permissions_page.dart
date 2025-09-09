import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../controllers/permissions_controller.dart';
import '../../../../widgets/body_wrapper.dart';
import 'widgets/permission_tile.dart';

class PermissionsPage extends GetView<PermissionsController> {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Permisos del dispositivo',
        ),
      ),
      body: BodyWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12, left: 8),
              child: Text('Tus preferencias', style: TextStyle(color: Colors.grey)),
            ),
            Obx(() => Column(
              children: [
                PermissionTile(
                  icon: Icons.location_on,
                  label: 'Ubicación',
                  status: controller.locationGranted.value,
                  onTap: controller.requestLocation,
                ),
                PermissionTile(
                  icon: Icons.photo_camera,
                  label: 'Cámara',
                  status: controller.cameraGranted.value,
                  onTap: controller.requestCamera,
                ),
                PermissionTile(
                  icon: Icons.notifications,
                  label: 'Notificaciones',
                  status: controller.notificationsGranted.value,
                  onTap: controller.requestNotifications,
                ),
                PermissionTile(
                  icon: Icons.mic,
                  label: 'Micrófono',
                  status: controller.microphoneGranted.value,
                  onTap: controller.requestMicrophone,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
