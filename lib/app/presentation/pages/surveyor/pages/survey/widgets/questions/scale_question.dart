import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';

class ScaleQuestion extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const ScaleQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final int scaleMin = question.scaleMin ?? 1;
    final int scaleMax = question.scaleMax ?? 10;
    final int scaleRange = scaleMax - scaleMin + 1;
    final scheme = Theme.of(context).extension<AppColorScheme>()!;

    return FormField(
      validator: controller.validatorMandatory(question),
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // izquierda
                Expanded(
                  child: Text(
                    question.anchorMin ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(width: 8),
                // derecha
                Expanded(
                  child: Text(
                    question.anchorMax ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            Obx(() {
              final int rating =
                  controller.responses[question.id]?['value'] ?? scaleMin;

              return SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColorScheme.primary,
                  inactiveTrackColor: scheme.border,
                  thumbColor: AppColorScheme.primary,
                  overlayColor: AppColorScheme.primary.withOpacity(0.2),
                  valueIndicatorColor: AppColorScheme.primary,
                  activeTickMarkColor: scheme.border,
                  inactiveTickMarkColor: AppColorScheme.primary,
                  valueIndicatorTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Slider(
                  value: rating.toDouble(),
                  min: scaleMin.toDouble(),
                  max: scaleMax.toDouble(),
                  divisions: scaleRange - 1,
                  label: rating.toString(),
                  onChanged: (double value) {
                    controller.responses[question.id] = {
                      'value': value.toInt(),
                      'type': question.type,
                      'question': question.question,
                    };
                    state.didChange(value.toString());
                    state.validate();
                  },
                ),
              );
            }),
            if (state.hasError)
              Text(
                state.errorText ?? '',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        );
      },
    );
  }
}
