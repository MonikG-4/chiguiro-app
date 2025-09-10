import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';

class StarRatingQuestion extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const StarRatingQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final int minStars = int.tryParse(question.anchorMin ?? '1') ?? 1;
    final int maxStars = int.tryParse(question.anchorMax ?? '5') ?? 5;
    final int stars = maxStars - minStars + 1;
    double iconSize = (32 + (stars - 5) * (46 - 32) / (10 - 5)).clamp(32.0, 46.0);
    final scheme = Theme.of(context).extension<AppColorScheme>()!;


    return FormField(
      validator: controller.validatorMandatory(question),
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final int rating = controller.responses[question.id]?['value'] ?? 0;

              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(minStars.toString()),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(stars, (index) {
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: index < rating ? AppColorScheme.primary : scheme.border,
                              size: iconSize,
                            ),
                            onPressed: () {
                              if (rating == index + 1) {
                                controller.responses.remove(question.id);
                              } else {
                                controller.responses[question.id] = {
                                  'question': question.question,
                                  'type': question.type,
                                  'value': index + 1,
                                };
                              }
                              state.didChange(controller.responses[question.id]?['value']?.toString());
                              state.validate();
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Text(maxStars.toString()),
                ],
              );
            }),
            if (state.hasError && controller.responses[question.id]?['value'] == null)
              Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        );
      },
    );
  }
}