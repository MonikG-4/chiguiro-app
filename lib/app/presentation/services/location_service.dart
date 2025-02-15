import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  final RxBool hasPermission = false.obs;

  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    hasPermission.value = true;
    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      if (!hasPermission.value) {
        final permissionGranted = await checkPermission();
        if (!permissionGranted) return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<void> requestLocationPermission() async {
    final permissionGranted = await checkPermission();

    if (!permissionGranted) {
      Get.dialog(
        AlertDialog(
          title: const Text('Permiso de ubicación'),
          content: const Text(
              'Esta aplicación necesita acceso a tu ubicación para funcionar correctamente. '
                  '¿Deseas permitir el acceso?'
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Get.back();
                checkPermission();
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('No'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }
}