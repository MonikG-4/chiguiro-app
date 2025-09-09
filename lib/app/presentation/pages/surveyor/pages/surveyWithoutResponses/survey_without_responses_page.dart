import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../core/values/routes.dart';
import '../../../../../domain/entities/survey.dart';
import '../../../../widgets/custom_text_button_redirect.dart';
import '../../../../widgets/primary_button.dart';

class SurveyWithoutResponsesPage extends StatelessWidget {
  final Survey? survey;

  SurveyWithoutResponsesPage({super.key})
      : survey = Get.arguments?['survey'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          color: scheme.firstBackground,
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
                  'assets/images/Encuesta.png',
                  width: 242,
                  height: 193,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Responde tu primera encuesta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aún no tienes encuestas respondidas, ¡responde tu primera encuesta!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: scheme.onFirstBackground.withOpacity(0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),
                PrimaryButton(
                  onPressed: () => Get.offNamed(
                    Routes.SURVEY,
                    arguments: {
                      'survey': survey,
                    },
                  ),
                  isLoading: false,
                  text: 'Iniciar encuesta',
                ),
                const SizedBox(height: 16),
                CustomTextButtonRedirect(
                  onPressed: () => Get.offAllNamed(Routes.DASHBOARD),
                  label: 'Volver al inicio',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
