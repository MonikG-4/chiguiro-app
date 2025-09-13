import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/pending_survey_controller.dart';
import '../../../../widgets/confirmation_dialog.dart';
import '../../widgets/body_wrapper.dart';
import '../../../../../../core/theme/app_colors_theme.dart';
import 'widgets/empty_pending.dart';
import 'widgets/pending_tile.dart';

class PendingSurveysPage extends GetView<PendingSurveyController> {
  const PendingSurveysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;

    return Obx(() {
      final items = controller.surveyPending;
      if (items.isEmpty) return const EmptyState();

      return BodyWrapper(
        onRefresh: () async =>
            controller.fetchSurveys(controller.idSurveyor.value),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Encuestas pendientes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Estas encuestas se guardaron porque no tenías conexión al momento de enviarlas. '
                  'Se enviarán automáticamente cuando tengas internet o puedes subirlas manualmente con el botón.',
              style: TextStyle(
                fontSize: 14,
                color: scheme.secondaryText,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),

            // Botón sincronizar
            Obx(() {
              final loading = controller.isSendingSurveys.value;
              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: loading
                      ? null
                      : () async {
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
                  icon: loading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Sincronizar Encuestas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.secondButtonBackground,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            const Text('Guardadas localmente',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),

            PendingList(controller: controller),
          ],
        ),
      );
    });
  }
}