import 'package:chiguiro_front_app/app/presentation/widgets/custom_text_button_redirect.dart';
import 'package:chiguiro_front_app/app/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/values/app_colors.dart';
import '../../../../../../core/values/routes.dart';

class SurveyWithoutResponses extends GetView {
  const SurveyWithoutResponses({super.key});

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
                const PrimaryButton(
                    onPressed: null,
                    isLoading: false,
                    child: 'Iniciar encuesta'
                ),
                const SizedBox(height: 16),
                CustomTextButtonRedirect(onPressed: ()=> Get.offAllNamed(Routes.DASHBOARD_SURVEYOR) , label: 'Volver al inicio'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
