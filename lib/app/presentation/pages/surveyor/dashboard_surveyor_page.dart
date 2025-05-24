import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/routes.dart';
import '../../controllers/session_controller.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/connectivity_banner.dart';
import '../../widgets/primary_button.dart';
import './widgets/survey_card.dart';
import '../../../../core/values/app_colors.dart';
import '../../../domain/entities/survey.dart';
import '../../controllers/dashboard_surveyor_controller.dart';
import 'widgets/download_splash.dart';
import 'widgets/home_code_widget.dart';
import 'widgets/response_survey_list.dart';
import 'widgets/surveyor_balance_card.dart';
import 'widgets/profile_header.dart';

class DashboardSurveyorPage extends GetView<DashboardSurveyorController> {
  const DashboardSurveyorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCodeController = Get.find<HomeCodeController>();

    return Obx(() {
      // Mostrar splash durante inicialización o descarga
      if (controller.isDownloadingSurveys.value && controller.connectivityService.isOnline) {
        return const Scaffold(
          body: DownloadSplash(),
        );
      }

      // Mostrar dashboard normal una vez cargado
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 190,
                  child: _buildAppBarBackground(context),
                ),
                const SizedBox(height: 70),
                // Scroll solo para el contenido
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Refresh normal sin splash (ya que no es carga inicial)
                      controller.refreshAllData();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 140,
              left: 16,
              right: 16,
              child: Obx(() {
                return SurveyorBalanceCard(
                  isLoading: controller.isSurveyorDataLoading.value,
                  responses: controller.dataSurveyor.value?.totalEntries ?? 0,
                  lastSurveyDate:
                  controller.dataSurveyor.value?.lastSurvey ?? '-- -- -- --',
                );
              }),
            ),
          ],
        ),
        bottomNavigationBar: Obx(() => controller.showContent.value
            ? Container(
          padding: const EdgeInsets.only(bottom: 30, right: 16, left: 16),
          color: AppColors.background,
          child: PrimaryButton(
            onPressed: () async {
              final confirmed = await Get.dialog<bool>(
                const ConfirmationDialog(
                  message: "¿Estás seguro de que deseas finalizar el hogar?",
                  confirmText: 'Finalizar',
                ),
              );
              if (confirmed == true) {
                controller.showContent.value = false;
                homeCodeController.resetHomeCode();
              }
            },
            isLoading: false,
            child: 'Finalizar hogar',
          ),
        )
            : const SizedBox.shrink()),
      );
    });
  }

  Widget _buildAppBarBackground(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Container(
      height: 170,
      padding: EdgeInsets.only(top: isIOS ? 10 : 20, right: 16, left: 16),
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundSecondary,
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        toolbarHeight: isIOS ? 50 : kToolbarHeight,
        centerTitle: false,
        titleSpacing: 0,
        title: ProfileHeader(
            name: 'Hola ${controller.nameSurveyor.value} ${controller.surnameSurveyor.value}',
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
              _buildSectionHeader('Formularios'),
              const SizedBox(height: 16),
              _buildSurveysList(),
              const SizedBox(height: 24),
              _buildSectionHeader('Encuestas realizadas'),
              const SizedBox(height: 16),
              _buildSurveysRespondedList()
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

  Widget _buildSurveysList() {
    final activeSurveys = controller.surveys.where((survey) => survey.active).toList();

    if (activeSurveys.isEmpty) {
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
      children: activeSurveys.map((survey) {
        return SurveyCard(
          survey: survey,
          onTap: () => _redirectToSurvey(survey),
        );
      }).toList(),
    );
  }


  Widget _buildSurveysRespondedList() {
    if (controller.surveysResponded.isEmpty) {
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
      children: [
        ResponseSurveyList(
          surveyResponded: controller.surveysResponded,
          isLoadingAnswerSurvey: controller.isSurveysRespondedLoading,
        ),
      ]
    );
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
                  })?.then((_) => controller.refreshAllData(all: false));
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
