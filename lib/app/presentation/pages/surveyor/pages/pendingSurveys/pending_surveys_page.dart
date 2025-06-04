import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../data/models/survey_entry_model.dart';
import '../../../../controllers/pending_survey_controller.dart';
import '../../../../widgets/confirmation_dialog.dart';
import '../../widgets/body_wrapper.dart';
import '../../widgets/custom_card.dart';

class PendingSurveysPage extends GetView<PendingSurveyController> {
  const PendingSurveysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BodyWrapper(
        onRefresh: () async => controller.fetchSurveys(controller.idSurveyor.value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Encuestas pendientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Estas encuestas se guardaron porque no tenías conexión al momento de enviarlas...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            CustomCard(children: [
              const Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              _buildPendingSummary(),
            ]),
            const SizedBox(height: 24),
            Obx(() => CustomCard(
              children: [
                const Text("Guardadas localmente", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                controller.surveyPending.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No hay encuestas pendientes',
                      style: TextStyle(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                    : _buildPendingList(),
              ],
            )),

          ],
        ),
      );
  }

  Widget _buildPendingSummary() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9F44),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sync_outlined, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Encuestas por sincronizar',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.1),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  '${controller.surveyPending.length}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final confirmed = await Get.dialog<bool>(
                const ConfirmationDialog(
                  message: '¿Deseas sincronizar todas las encuestas?',
                  confirmText: 'Iniciar',
                ),
              );
              if (confirmed == true) {
                await controller.saveAllPendingSurveys();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F9F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF48C9B0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Sincronizar encuestas',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.1),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Iniciar',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingList() {
    return Column(
      children: controller.surveyPending.map((survey) {
        final surveyName = survey['surveyName'] ?? 'Encuesta sin nombre';
        final payload = survey['payload'] as SurveyEntryModel;
        final formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'es')
            .format(DateTime.parse(payload.finishedOn));

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeadingIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surveyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$formattedDate | ${payload.homeCode}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      }).toList(),
    );
  }

  Widget _buildLeadingIcon() {
    return Image.asset(
      'assets/images/min-deporte.png',
      width: 60,
      height: 60,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.business,
        size: 40,
      ),
    );
  }


}
