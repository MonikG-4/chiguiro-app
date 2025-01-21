import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/routes.dart';
import '../../controllers/session_controller.dart';
import './widgets/survey_card.dart';
import '../../../../core/values/app_colors.dart';
import '../../../domain/entities/survey.dart';
import '../../controllers/auth_storage_controller.dart';
import '../../controllers/dashboard_surveyor_controller.dart';
import 'widgets/surveyor_balance_card.dart';
import 'widgets/profile_header.dart';

class DashboardSurveyorPage extends GetView<DashboardSurveyorController> {
  const DashboardSurveyorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(178.0),
        child: Obx(() {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              _buildAppBarBackground(context),
              Positioned(
                top: 120.0,
                left: 16.0,
                right: 16.0,
                child: SurveyorBalanceCard(
                  balance: controller.surveyor.value?.balance ?? 0,
                  responses: controller.surveyor.value?.responses ?? 0,
                  growthRate: controller.surveyor.value?.growthRate ?? 0,
                  lastSurveyDate: '06. ene. 2025',
                ),
              ),
            ],
          );
        }),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildContent();
        }),
      ),
    );
  }

  Widget _buildAppBarBackground(BuildContext context) {
    final authController = Get.find<AuthStorageController>();

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
              'Hola ${authController.user?.name ?? ''} ${authController.user?.surname ?? ''}',
          role: controller.surveyor.value?.role ?? '',
          avatarPath: 'assets/images/icons/Male.png',
          onSettingsTap: () => _showSettingsModal(context),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 64,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Mis encuestas', isActive: true),
                  const SizedBox(height: 16),
                  _buildSurveysList(controller.activeSurveys),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Historial de encuestas'),
                  const SizedBox(height: 16),
                  _buildSurveysList(
                    controller.activeSurveys,
                    isHistorical: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

  void _redirectToSurvey(Survey survey) {
    if (survey.responses > 0) {
      Get.toNamed(Routes.SURVEY_DETAIL, arguments: survey);
    } else {
      Get.toNamed(Routes.SURVEY_WITHOUT_RESPONSE);
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
