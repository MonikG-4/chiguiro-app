import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/routes.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/connectivity_banner.dart';
import '../../widgets/primary_button.dart';
import './widgets/survey_card.dart';
import '../../../../core/values/app_colors.dart';
import '../../../domain/entities/survey.dart';
import '../../controllers/dashboard_surveyor_controller.dart';
import 'widgets/home_code_widget.dart';
import 'widgets/surveyor_balance_card.dart';
import 'widgets/profile_header.dart';

class DashboardSurveyorPage extends GetView<DashboardSurveyorController> {
  const DashboardSurveyorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCodeController = Get.find<HomeCodeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshAllData();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 178.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildAppBarBackground(context),
                    Positioned(
                      top: 130.0,
                      left: 16.0,
                      right: 16.0,
                      child: Obx(() {
                        return SurveyorBalanceCard(
                          isLoading: controller.isSurveyorDataLoading.value,
                          responses:
                              controller.dataSurveyor.value?.totalEntries ?? 0,
                          lastSurveyDate:
                              controller.dataSurveyor.value?.lastSurvey ??
                                  '-- -- -- --',
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => controller.showContent.value
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.background,
              child: PrimaryButton(
                onPressed: () => _showConfirmationDialog(context, homeCodeController),
                isLoading: false,
                child: 'Finalizar hogar',
              ),
            )
          : const SizedBox.shrink()),
    );
  }

  void _showConfirmationDialog(BuildContext context, HomeCodeController homeCodeController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmación"),
          content: const Text("¿Estás seguro de que deseas finalizar el hogar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.showContent.value = false;
                homeCodeController.resetHomeCode();
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBarBackground(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundSecondary,
      ),
      padding: const EdgeInsets.only(top: 16),
      child: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: ProfileHeader(
          name:
              'Hola ${controller.nameSurveyor.value} ${controller.surnameSurveyor.value}',
          role: 'Encuestador',
          avatarPath: 'assets/images/icons/Male.png',
          onSettingsTap: () => _showSettingsModal(context),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.only(
        top: 70,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConnectivityBanner(),
          HomeCodeWidget(
            onCodeGenerated: (homeCode) {
              controller.showContent.value = true;
              controller.homeCode.value = homeCode;
              controller.fetchSurveysResponded(homeCode);
            },
          ),
          Obx(() => controller.showContent.value
              ? controller.isSurveysLoading.value
                  ? const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Rango de edad'),
                        const SizedBox(height: 16),
                        _buildSurveysList(controller.surveys),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Rango de edad encuestados'),
                        const SizedBox(height: 16),
                        _buildSurveysList(
                          controller.surveysResponded,
                          isHistorical: true,
                        )
                      ],
                    )
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isActive = false}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isActive) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              border: Border.all(color: AppColors.successBorder),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Text(
              'Activas',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.successText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSurveysList(List<Survey> surveys, {bool isHistorical = false}) {

    if (surveys.isEmpty) {
      return const Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "No hay encuestas disponibles",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Column(
      children: surveys.map((survey) {
        return SurveyCard(
          survey: survey,
          isHistorical: isHistorical,
          onTap: () => isHistorical ? null : _redirectToSurvey(survey),
        );
      }).toList(),
    );
  }

  Future<void> _redirectToSurvey(Survey survey) async {
    if (survey.entriesCount > 0) {
      await Get.toNamed(
        Routes.SURVEY_DETAIL,
        arguments: {
          'survey': survey,
          'homeCode': controller.homeCode.value,
        },
      )?.then((_) => controller.refreshAllData());
    } else {
      Get.toNamed(
        Routes.SURVEY_WITHOUT_RESPONSE,
        arguments: {
          'survey': survey,
          'homeCode': controller.homeCode.value,
        },
      );
    }
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.watch_later_outlined),
                title: const Text('Encuestas pendientes'),
                onTap: () async {
                  await Get.toNamed(Routes.PENDING_SURVEYS, arguments: {
                    'surveyorId': controller.idSurveyor.value,
                  })?.then((_) => controller.refreshAllData());

                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Cambiar contraseña'),
                onTap: () {
                  Get.toNamed(Routes.CHANGE_PASSWORD);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  final sessionController = Get.find<SessionController>();
                  sessionController.logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
