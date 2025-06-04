import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/values/routes.dart';

class PermissionsController extends GetxController {
  final locationGranted = false.obs;
  final cameraGranted = false.obs;
  final notificationsGranted = false.obs;
  final microphoneGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    locationGranted.value = await Permission.location.isGranted;
    cameraGranted.value = await Permission.camera.isGranted;
    notificationsGranted.value = await Permission.notification.isGranted;
    microphoneGranted.value = await Permission.microphone.isGranted;
  }

  // Navegación al detalle de permisos
  void goToPermissionDetail({
    required String title,
    required bool isGranted,
    required String allowedTitle,
    required String allowedDescription,
    required String deniedTitle,
    required String deniedDescription,
  }) {
    Get.toNamed(
      Routes.PERMISSION_DETAIL,
      arguments: {
        'title': title,
        'isGranted': isGranted,
        'allowedTitle': allowedTitle,
        'allowedDescription': allowedDescription,
        'deniedTitle': deniedTitle,
        'deniedDescription': deniedDescription,
      },
    );
  }

  Future<void> requestLocation() async {
    final result = await Permission.location.request();
    locationGranted.value = result.isGranted;
    goToPermissionDetail(
      title: 'Ubicación',
      isGranted: locationGranted.value,
      allowedTitle: 'Permitido',
      allowedDescription: 'Chigüiro tiene permiso para acceder a tu ubicación.',
      deniedTitle: 'No permitido',
      deniedDescription: 'Chigüiro no tiene permiso para acceder a tu ubicación.',
    );

  }

  Future<void> requestCamera() async {
    final result = await Permission.camera.request();
    cameraGranted.value = result.isGranted;
    goToPermissionDetail(
      title: 'Cámara',
      isGranted: cameraGranted.value,
      allowedTitle: 'Permitido',
      allowedDescription: 'Chigüiro tiene permiso para acceder a la cámara.',
      deniedTitle: 'No permitido',
      deniedDescription: 'Chigüiro no tiene permiso para acceder a la cámara.',
    );
  }

  Future<void> requestNotifications() async {
    final result = await Permission.notification.request();
    notificationsGranted.value = result.isGranted;
    goToPermissionDetail(
      title: 'Notificaciones',
      isGranted: notificationsGranted.value,
      allowedTitle: 'Permitido',
      allowedDescription: 'Chigüiro puede enviarte notificaciones.',
      deniedTitle: 'No permitido',
      deniedDescription: 'Chigüiro no puede enviarte notificaciones.',
    );
  }

  Future<void> requestMicrophone() async {
    final result = await Permission.microphone.request();
    microphoneGranted.value = result.isGranted;
    goToPermissionDetail(
      title: 'Micrófono',
      isGranted: microphoneGranted.value,
      allowedTitle: 'Permitido',
      allowedDescription: 'Chigüiro tiene permiso para usar el micrófono.',
      deniedTitle: 'No permitido',
      deniedDescription: 'Chigüiro no tiene permiso para usar el micrófono.',
    );
  }
}
