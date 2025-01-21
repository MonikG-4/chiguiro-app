import 'package:chiguiro_front_app/app/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/values/app_colors.dart';
import '../../../../../domain/entities/survey.dart';
import '../../widgets/ResponseStatusList.dart';
import '../../widgets/profile_header.dart';
import '../../widgets/survey_detail_card.dart';

class SurveyDetail extends GetView {
  final Survey? survey;

  SurveyDetail({super.key}) : survey = Get.arguments;
  final items = [
    ResponseStatus(
      date: DateTime(2025, 12, 15),
      responsePercentage: 0.4625,
      isComplete: false,
    ),
    ResponseStatus(
      date: DateTime(2025, 12, 15),
      responsePercentage: 0.4625,
      isComplete: true,
    ),
    ResponseStatus(
      date: DateTime(2025, 12, 15),
      responsePercentage: 0.4625,
      isComplete: false,
    ),
    ResponseStatus(
      date: DateTime(2024, 12, 13),
      responsePercentage: 0.4625,
      isComplete: false,
    ),
    ResponseStatus(
      date: DateTime(2024, 12, 12),
      responsePercentage: 0.4625,
      isComplete: true,
    ),
    ResponseStatus(
      date: DateTime(2025, 12, 15),
      responsePercentage: 0.4625,
      isComplete: true,
    ),
    ResponseStatus(
      date: DateTime(2025, 12, 15),
      responsePercentage: 0.4625,
      isComplete: false,
    ),
    ResponseStatus(
      date: DateTime(2025, 12, 13),
      responsePercentage: 0.4625,
      isComplete: false,
    ),
    ResponseStatus(
      date: DateTime(2025, 12, 12),
      responsePercentage: 0.4625,
      isComplete: true,
    ),
  ];

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
                responses: survey!.responses,
                lastSurveyDate: '06. ene. 2025',
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
        titleSpacing: -15, // Reduce el espacio entre el icono y el título
        title: ProfileHeader(
          name: survey!.name,
          role: 'Cierra el ${_formatDate(survey!.closeDate)}',
          avatarPath: survey!.logoUrl!,
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
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
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
                  ResponseStatusList(items: items),
                  PrimaryButton(
                    onPressed: null,
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
