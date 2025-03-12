import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/values/app_colors.dart';
import '../../../../../data/models/survey_entry_model.dart';
import '../../../../controllers/survey_controller.dart';

class PendingSurveysPage extends GetView<SurveyController> {
  final int? _surveyorId;

  PendingSurveysPage({super.key}) : _surveyorId = Get.arguments['surveyorId'];

  @override
  Widget build(BuildContext context) {
    if (_surveyorId == null) {
      return const Scaffold(
        body: Center(child: Text('ID del encuestador no disponible')),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSurveys(_surveyorId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuestas pendientes'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await controller.fetchSurveys(_surveyorId);
            },
            child: Obx(() => controller.surveyPending.isEmpty
                ? const Center(child: Text('No hay encuestas pendientes'))
                : ListView.builder(
              itemCount: controller.surveyPending.length,
              itemBuilder: (context, index) {
                final survey = controller.surveyPending[index];
                final surveyName = survey['surveyName'] ?? 'Encuesta sin nombre';
                final payload = survey['payload'] as SurveyEntryModel;
                final formattedDate = DateFormat('dd-MM-yyyy HH:mm')
                    .format(DateTime.parse(payload.finishedOn));

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    title: Text(surveyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(formattedDate),
                    trailing: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        controller.saveSurveyResults(_surveyorId, survey);
                      },
                    ),
                  ),
                );
              },
            )),
          ),
          Obx(() => controller.isLoadingSendSurvey.value
              ? Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
