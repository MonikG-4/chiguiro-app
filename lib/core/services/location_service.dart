import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  final RxBool hasPermission = false.obs;
  Position? cachedPosition;

  Future<void> initializeCachedPosition() async {
    if (!await _checkPermission()) return;
    cachedPosition = await _getCurrentLocation(forceRefresh: true);
  }

  Future<void> requestLocationPermission() async {
    if (!await _checkPermission()) {
      _showPermissionDialog();
    }
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
      _showPermissionDialog();
      return false;
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
      print('Error obteniendo la ubicación: \$e');
      return null;
    }
  }

  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Permiso de ubicación requerido'),
        content: const Text('Para continuar, habilita el acceso a la ubicación en la configuración.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openAppSettings();
            },
            child: const Text('Abrir configuración'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
