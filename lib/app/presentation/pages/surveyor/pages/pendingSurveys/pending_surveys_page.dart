import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../data/models/survey_entry_model.dart';
import '../../../../controllers/pending_survey_controller.dart';
import '../../../../widgets/confirmation_dialog.dart';
import '../../widgets/body_wrapper.dart';
import '../../widgets/custom_card.dart';
import '../../../../../../core/theme/app_colors_theme.dart';

class PendingSurveysPage extends GetView<PendingSurveyController> {
  const PendingSurveysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;

    return Obx(() {
      final items = controller.surveyPending;
      final hasPending = items.isNotEmpty;

      return BodyWrapper(
        onRefresh: () async =>
            controller.fetchSurveys(controller.idSurveyor.value),
        child: hasPending
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado SOLO si hay pendientes
                  const Text(
                    'Encuestas pendientes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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

                  // Botón grande
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Obx(() {
                      final loading = controller.isSendingSurveys.value;
                      return ElevatedButton.icon(
                        onPressed: loading
                            ? null
                            : () async {
                                final confirmed = await Get.dialog<bool>(
                                  const ConfirmationDialog(
                                    message:
                                        '¿Deseas sincronizar todas las encuestas?',
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
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Listado "Guardadas localmente"
                  const Text(
                    'Guardadas localmente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  if (controller.isSendingSurveys.value)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Column(
                      children:
                          items.map((s) => _PendingTile(survey: s)).toList(),
                    ),
                ],
              )
            : const _EmptyState(), // ← si NO hay pendientes, sólo empty state
      );
    });
  }
}

class _PendingTile extends StatelessWidget {
  final Map<String, dynamic> survey;
  const _PendingTile({required this.survey});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    final surveyName = survey['surveyName'] ?? 'Encuesta sin nombre';
    final payload = survey['payload'] as SurveyEntryModel;
    final formattedDate = DateFormat('d \'de\' MMMM yyyy HH:mm', 'es')
        .format(DateTime.parse(payload.finishedOn));

    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? scheme.secondBackground
        : Colors.white;

    return Card(
      child: ListTile(
        leading: _LeadingIcon(),
        title: Text(
          surveyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: scheme.onFirstBackground.withOpacity(0.55),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  formattedDate,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onFirstBackground.withOpacity(0.65),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
        // trailing: const Icon(Icons.chevron_right), // opcional
        // onTap: () {}, // si luego quieres abrir detalle
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/images/min-deporte.png',
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColorScheme.infoBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.description_outlined, size: 24),
        ),
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Column(
          children: [
            Image.asset(
              'assets/images/clock.png',
              width: 96,
              height: 96,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.access_time_rounded,
                  size: 92,
                  color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text('Encuestas pendientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Aquí se guardarán las encuestas que no pudieron enviarse por falta de conexión. '
              'Se enviarán automáticamente al reconectarte o puedes subirlas manualmente con el botón.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.secondaryText, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}
