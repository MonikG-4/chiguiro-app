import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/values/app_colors.dart';
import '../../../../../../core/values/routes.dart';
import '../../../../widgets/custom_text_button_redirect.dart';
import '../../../../widgets/primary_button.dart';

class SurveyWithoutResponsesPage extends GetView {
  const SurveyWithoutResponsesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 35),
                Image.asset(
                  'assets/images/icons/Encuesta.png',
                  width: 242,
                  height: 193,
                ),
                const Text(
                  'Responde tu primera encuesta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No tienes encuestas sin respuestas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 64),
                PrimaryButton(
                    onPressed: (() => Get.toNamed(Routes.SURVEY)),
                    isLoading: false,
                    child: 'Iniciar encuesta'),
                const SizedBox(height: 16),
                CustomTextButtonRedirect(
                    onPressed: () => Get.offAllNamed(Routes.DASHBOARD_SURVEYOR),
                    label: 'Volver al inicio'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
