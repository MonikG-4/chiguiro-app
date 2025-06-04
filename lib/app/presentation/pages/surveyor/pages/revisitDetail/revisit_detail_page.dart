import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../core/values/app_colors.dart';
import '../../../../../../core/values/routes.dart';
import '../../../../../domain/entities/survey.dart';
import '../../../../controllers/revisit_detail_controller.dart';
import '../../../../widgets/confirmation_dialog.dart';
import '../../../../widgets/primary_button.dart';
import '../../widgets/body_wrapper.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/revisit_map_view.dart';
import '../../widgets/survey_display_section.dart';
import '../../widgets/home_code_widget.dart';

class RevisitDetailPage extends GetView<RevisitDetailController> {
  const RevisitDetailPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(
          title: const Text('Revisitas'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Obx(() => BodyWrapper(
          onRefresh: () async {
            await controller.refreshAllData();
          },
          bottomButton: SafeArea(
            minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom + 8,
              left: 8,
              right: 8,
              top: 4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    onPressed: () async {
                      final confirmed = await Get.dialog<bool>(
                        const ConfirmationDialog(
                          message: "¿Estás seguro de que deseas finalizar el hogar?",
                          confirmText: 'Finalizar',
                        ),
                      );
                      if (confirmed == true) {
                        controller.saveRevisit();
                        Get.back();
                      }
                    },
                    backgroundColor: AppColors.secondaryButton,
                    isLoading: false,
                    child: 'Guardar hogar',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () async {
                      final confirmed = await Get.dialog<bool>(
                        const ConfirmationDialog(
                          message: "¿Estás seguro de que deseas finalizar el hogar?",
                          confirmText: 'Finalizar',
                        ),
                      );
                      if (confirmed == true) {
                        controller.deleteRevisit();
                        Get.back();
                      }
                    },
                    isLoading: false,
                    child: 'Finalizar hogar',
                  ),
                ),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HomeCodeWidget(
                homeCode: controller.revisit.value!.homeCode,
                readOnly: true,
              ),
              const SizedBox(height: 20),

              CustomCard(
                children: [
                  const Text('Detalle de la revisita',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.revisit.value!.reason,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Dirección',
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    controller.revisit.value!.address,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  /// 👉 Sección modificada con FutureBuilder
                  FutureBuilder<List<LatLng>>(
                    future: controller.getCurrentToRevisitRoute(controller.revisit.value!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return RevisitMapView(
                        coordinates: snapshot.data!,
                        drawLine: true,
                        zoom: 15,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() {
                if (controller.isSurveysLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SurveyDisplaySection(
                      title: 'Formularios',
                      surveys: controller.surveys.toList(),
                      isResponded: false,
                      onSurveyTap: (survey) => _redirectToSurvey(survey),
                      isLoading: controller.isSurveysLoading,
                    ),
                    const SizedBox(height: 8),

                    CustomCard(
                      children: [
                        SurveyDisplaySection(
                          title: 'Encuestas realizadas',
                          surveys: controller.surveysResponded.toList(),
                          isResponded: true,
                          isLoading: controller.isSurveysLoading,
                        ),
                      ],
                    ),

                    const SizedBox(height: 42),
                  ],
                );
              })
            ],
          ),

          ),
        ),
        );
  }

  Future<void> _redirectToSurvey(Survey survey) async {
    if (survey.entriesCount > 0) {
      await Get.toNamed(
        Routes.SURVEY,
        arguments: {
          'survey': survey,
          'homeCode': controller.homeCode.value,
          'revisit': controller.revisit.value,
        },
      )?.then((_) => controller.refreshAllData(all: false));
    } else {
      await Get.toNamed(
        Routes.SURVEY_WITHOUT_RESPONSE,
        arguments: {
          'survey': survey,
          'homeCode': controller.homeCode.value,
          'revisit': controller.revisit.value,
        },
      )?.then((_) => controller.refreshAllData(all: false));
    }
  }
}
