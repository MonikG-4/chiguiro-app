import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/values/app_colors.dart';
import '../../../../../../core/values/routes.dart';
import '../../../../controllers/detail_survey_controller.dart';
import '../../../../widgets/connectivity_banner.dart';
import '../../../../widgets/primary_button.dart';
import 'widgets/response_status_list.dart';
import '../../widgets/profile_header.dart';
import 'widgets/survey_detail_card.dart';

class SurveyDetailPage extends GetView<DetailSurveyController> {
  final String? homeCode;

  SurveyDetailPage({super.key}) : homeCode = Get.arguments['homeCode'];

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height - 540;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final estimatedPageSize = (availableHeight / 30).floor();

      controller.pageSize.value = estimatedPageSize;
      controller.fetchData(clearData: true);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                controller.fetchData(clearData: true);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          children: [
                            _buildAppBarBackground(context),
                            Container(
                              height: 80,
                              color: AppColors.background,
                            ),
                          ],
                        ),
                        Positioned(
                          top: 130,
                          left: 16,
                          right: 16,
                          child: Obx(() {
                            return SurveyDetailCard(
                              isLoading: controller.isLoadingStatisticSurvey.value,
                              responses: controller.surveyStatistics.value?.totalEntries ?? 0,
                              lastSurveyDate: (controller.surveyStatistics.value?.lastSurvey.toIso8601String() == '1970-01-01T00:00:00.000')
                                  ? '-- -- -- --'
                                  : controller.surveyStatistics.value?.lastSurvey.toIso8601String() ?? '-- -- -- --',
                              values: [
                                controller.surveyStatistics.value?.totalCompleted ?? 0,
                                controller.surveyStatistics.value?.totalUncompleted ?? 0,
                              ],
                              weekDays: const ['Completas', 'Incompletas'],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _buildContent(availableHeight),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
            child: PrimaryButton(
              onPressed: (() async {
                await Get.toNamed(
                  Routes.SURVEY,
                  arguments: {
                    'survey': controller.survey.value,
                    'homeCode': homeCode,
                  },
                )?.then((_) => controller.fetchData(clearData: true));
              }),
              isLoading: false,
              child: 'Iniciar encuesta',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarBackground(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Container(
      height: 170,
      padding: EdgeInsets.only(top: isIOS ? 10 : 20),
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundSecondary,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: -15,
        title: ProfileHeader(
          name: controller.survey.value!.name,
          role: controller.survey.value!.active! ? 'En proceso' : 'Finalizada',
          avatarPath: 'assets/images/min-deporte.png',
        ),
      ),
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

  Widget _buildContent(double availableHeight) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(
        top: 155,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConnectivityBanner(),

          _buildSectionHeader('Mis respuestas'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
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
          ResponseStatusList(maxHeight: availableHeight),
        ],
      ),
    );
  }
}
