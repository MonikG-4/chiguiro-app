import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_detail_page.dart';

class PermissionDetailWrapper extends StatelessWidget {
  const PermissionDetailWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;

    return PermissionDetailPage(
      title: args['title'] ?? 'Permiso',
      isGranted: args['isGranted'] ?? false,
      allowedTitle: args['allowedTitle'] ?? 'Permitido',
      allowedDescription: args['allowedDescription'] ?? '',
      deniedTitle: args['deniedTitle'] ?? 'No permitido',
      deniedDescription: args['deniedDescription'] ?? '',
      onOpenSettings: openAppSettings,
    );
  }
}
