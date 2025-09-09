import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/theme/app_colors_theme.dart';

class ConnectivityBanner extends StatelessWidget {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_connectivityService.isOnline) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: AppColorScheme.errorBackground,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: AppColorScheme.errorText),
              SizedBox(width: 8),
              Text(
                'Sin conexión a internet',
                style:
                TextStyle(color: AppColorScheme.errorText,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
