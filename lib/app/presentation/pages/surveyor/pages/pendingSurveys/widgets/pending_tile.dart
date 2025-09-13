import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../data/models/survey_entry_model.dart';
import '../../../../../controllers/pending_survey_controller.dart';

class PendingList extends StatelessWidget {
  final PendingSurveyController controller;
  const PendingList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSendingSurveys.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: controller.surveyPending
            .map((s) => _PendingTile(survey: s))
            .toList(),
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

    return Card(
      child: ListTile(
        leading: ClipRRect(
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
        ),
        title: Text(
          surveyName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 14, color: scheme.onFirstBackground.withOpacity(0.55)),
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
          ],
        ),
      ),
    );
  }
}