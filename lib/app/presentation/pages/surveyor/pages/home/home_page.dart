import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/values/routes.dart';
import '../../../../widgets/confirmation_dialog.dart';
import '../../../../widgets/connectivity_banner.dart';
import '../../../../widgets/primary_button.dart';
import '../../widgets/body_wrapper.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/survey_display_section.dart';
import '../../../../../../core/values/app_colors.dart';
import '../../../../../domain/entities/survey.dart';
import '../../../../controllers/home_controller.dart';
import '../../widgets/home_code_widget.dart';
import 'widgets/revisit_dialog.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => BodyWrapper(
          onRefresh: () async {
            controller.isDownloadingSurveys.value = true;
            await controller.refreshAllData();
            controller.isDownloadingSurveys.value = false;
          },
          showBottomButton: controller.showContent.value,
          bottomButton: controller.showContent.value
              ? Row(
                  children: [
                    // Botón guardar hogar
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () async {
                          final reason = await Get.dialog<String>(
                            const RevisitDialog(
                              message:
                                  "¿Quieres guardar este hogar para una revisita?\n"
                                  "Cuéntanos el motivo de la revisita:",
                            ),
                          );

                          if (reason != null && reason.isNotEmpty) {
                            controller.saveRevisit(reason);
                          }
                        },
                        backgroundColor: AppColors.secondaryButton,
                        isLoading: false,
                        child: 'Guardar hogar',
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón Finalizar hogar
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () async {
                          final confirmed = await Get.dialog<bool>(
                            const ConfirmationDialog(
                              message:
                                  "¿Estás seguro de que deseas finalizar el hogar?",
                              confirmText: 'Finalizar',
                            ),
                          );
                          if (confirmed == true) {
                            controller.showContent.value = false;
                            controller.resetHomeCode();
                          }
                        },
                        isLoading: false,
                        child: 'Finalizar hogar',
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConnectivityBanner(),

              // Mostrar siempre el código (aunque esté vacío)
              HomeCodeWidget(
                homeCode: controller.homeCode.value,
                readOnly: true,
              ),

              const SizedBox(height: 16),

              // Si no hay código, mostrar botón para generar uno
              if (controller.homeCode.value.isEmpty)
                PrimaryButton(
                  onPressed: () {
                    controller.generateHomeCode();
                    controller.showContent.value = true;
                    controller.fetchSurveysResponded(controller.homeCode.value);
                  },
                  isLoading: false,
                  child: 'Nuevo hogar',
                )
              else

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SurveyDisplaySection(
                      title: 'Formularios',
                      surveys: controller.surveys,
                      isResponded: false,
                      onSurveyTap: (survey) => _redirectToSurvey(survey),
                    ),
                    const SizedBox(height: 8),
                    // Si ya hay código generado, mostrar loading o contenido
                    controller.isSurveysRespondedLoading.value
                        ? const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                        :
                     CustomCard(
                      children: [
                        SurveyDisplaySection(
                          title: 'Encuestas realizadas',
                          surveys: controller.surveysResponded,
                          isResponded: true,
                          isLoading: controller.isSurveysRespondedLoading,
                        ),
                      ],
                    ),
                  ],
                ),

            ],
          ),
        ));
  }

  Future<void> _redirectToSurvey(Survey survey) async {
    if (survey.entriesCount > 0) {
      await Get.toNamed(
        Routes.SURVEY,
        arguments: {
          'survey': survey,
          'homeCode': controller.homeCode.value,
        },
      )?.then((_) => controller.refreshAllData(all: false));
    } else {
      await Get.toNamed(
        Routes.SURVEY_WITHOUT_RESPONSE,
        arguments: {
          'survey': survey,
          'homeCode': controller.homeCode.value,
        },
      )?.then((_) => controller.refreshAllData(all: false));
    }
  }
}
