import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../utils/message_handler.dart';
import '../utils/snackbar_message_model.dart';

class LocationService extends GetxService {
  final RxBool hasPermission = false.obs;
  Position? cachedPosition;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  @override
  Future<void> onInit() async {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);

  }

  Future<void> initializeCachedPosition() async {
    cachedPosition = await _getCurrentLocation(forceRefresh: true);
  }

  Future<bool> requestLocationPermission() async {
    return await _checkPermission();

  }

  Future<bool> _checkPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await _showSettingsDialog('ubicación');
    }

    hasPermission.value = permission == LocationPermission.whileInUse || permission == LocationPermission.always;
    return hasPermission.value;
  }


  Future<Position?> _getCurrentLocation({bool forceRefresh = false}) async {
    if (!hasPermission.value && !(await _checkPermission())) return null;

    if (!forceRefresh && cachedPosition != null) return cachedPosition;

    try {
      cachedPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return cachedPosition;
    } catch (e) {
      message.update((val) {
        val?.title = 'Servicio de ubicacion';
        val?.message = 'No se pudo detener la ubicación';
        val?.state = 'error';
      });
      return null;
    }
  }

  Future<void> _showSettingsDialog(String permissionType) async {
    await Get.dialog(
      AlertDialog(
        title: Text('Permiso de $permissionType requerido'),
        content: Text('Debes habilitar el acceso a tu $permissionType desde la configuración para continuar.'),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openAppSettings();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
