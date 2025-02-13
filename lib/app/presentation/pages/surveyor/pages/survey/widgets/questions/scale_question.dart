import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../../core/values/app_colors.dart';
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

    return FormField(
      validator: controller.validatorMandatory(question),
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(question.anchorMin ?? ''),
                Text(question.anchorMax ?? ''),
              ],
            ),
            Obx(() {
              final int rating = controller.responses[question.id]?['value'] ?? scaleMin;

              return SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.scale,
                  inactiveTrackColor: AppColors.scale,
                  thumbColor: AppColors.primaryButton,
                  overlayColor: AppColors.primaryButton.withOpacity(0.2),
                  valueIndicatorColor: AppColors.primaryButton,
                  activeTickMarkColor: AppColors.primaryButton,
                  inactiveTickMarkColor: AppColors.primaryButton,
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