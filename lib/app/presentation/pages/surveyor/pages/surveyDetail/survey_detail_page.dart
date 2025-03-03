import 'package:chiguiro_front_app/app/domain/entities/survey_statistics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/values/app_colors.dart';
import '../../../../../../core/values/routes.dart';
import '../../../../../domain/entities/survey.dart';
import '../../../../controllers/detail_survey_controller.dart';
import '../../../../widgets/primary_button.dart';
import 'widgets/response_status_list.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/survey_detail_card.dart';

class SurveyDetailPage extends GetView<DetailSurveyController> {

  const SurveyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(260.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildAppBarBackground(context),
            Positioned(
              top: 120.0,
              left: 16.0,
              right: 16.0,
              child: SurveyDetailCard(
                responses: controller.surveyStatistics.value?.totalEntries ?? 0,
                lastSurveyDate: '06. ene. 2025',
                values: [controller.surveyStatistics.value?.totalCompleted ?? 0, controller.surveyStatistics.value?.totalUncompleted ?? 0,],
                weekDays: const ['Completas', 'Incompletas'],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildAppBarBackground(BuildContext context) {
    var logoUrl = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFe4BEwG37Mv0M724WYCTjsNP2UojEL3Oa0Q&s';

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundSecondary,
      ),
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: -15,
        title: ProfileHeader(
          name: controller.survey.value!.name,
          role: controller.survey.value!.active ? 'En proceso' : 'Finazalida xxxx',
          avatarPath: logoUrl,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: AppColors.background,
              padding: const EdgeInsets.only(
                top: 90,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Mis respuestas'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Fecha',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3A4D),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '% de respuesta',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3A4D),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Estado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3A4D),
                            ),
                            textAlign: TextAlign.center,

                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE8EDF4)),
                  ResponseStatusList(),
                  PrimaryButton(
                    onPressed: (() => Get.toNamed(Routes.SURVEY, arguments: {
                      'survey': controller.survey.value,
                    },)),
                    isLoading: false,
                    child: 'Iniciar encuesta',
                  ),
                ],
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    return '${date.day}. ${months[date.month - 1]}. ${date.year}';
  }
}
