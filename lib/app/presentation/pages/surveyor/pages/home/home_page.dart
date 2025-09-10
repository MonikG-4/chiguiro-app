import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../core/values/routes.dart';
import '../../../../../domain/entities/survey.dart';
import '../../../../controllers/home_controller.dart';
import '../../../../widgets/confirmation_dialog.dart';
import '../../../../widgets/connectivity_banner.dart';
import '../../../../widgets/primary_button.dart';
import '../../widgets/body_wrapper.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/survey_display_section.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return Obx(() => BodyWrapper(
          onRefresh: () async {
            controller.isDownloadingSurveys.value = true;
            await controller.refreshAllData(forceServer: true);
            controller.isDownloadingSurveys.value = false;
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConnectivityBanner(),
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
                      : CustomCard(
                          color: scheme.onFirstBackground,
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
