import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/theme/app_colors_theme.dart';
import 'widgets/theme_mode_selector.dart';
import 'widgets/text_scale_selector.dart';

class AccessibilityPage extends StatelessWidget {

  const AccessibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accesibilidad'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
          onPressed: () => Get.back(),
          tooltip: 'Volver',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).extension<AppColorScheme>()!.secondBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const ThemeModeSettingItem(),
                Divider(height: 1, color: Theme.of(context).extension<AppColorScheme>()!.border,),
                const TextScaleSelector(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}