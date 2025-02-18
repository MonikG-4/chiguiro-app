import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/values/app_colors.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_input.dart';

class RadioInputQuestion extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const RadioInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: controller.validatorMandatory(question),
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...question.meta.map<Widget>((option) => Obx(() {
                  bool isSelected =
                      controller.responses[question.id]?['value'] == option;

                  void toggleSelection(String option) {
                    bool isSelected = controller.responses[question.id]?['value'] == option;
                    if (isSelected) {
                      controller.responses.remove(question.id);
                    } else {
                      controller.responses[question.id] = {
                        'question': question.question,
                        'type': question.type,
                        'value': option,
                      };
                    }

                    controller.handleJumper(question, isSelected ? '' : option);
                    controller.update();
                    state.didChange(controller.responses[question.id]?['value']
                        ?.toString());
                    state.validate();
                  }

                  return CustomInput(
                    hasError: state.hasError,
                    hasValue: controller.responses[question.id] != null,
                    onTap: () => toggleSelection(option),
                    isSelected: isSelected,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            option.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      Radio(
                        value: option,
                        groupValue: controller.responses[question.id]?['value'],
                        onChanged: (value) => toggleSelection(option),
                        activeColor: AppColors.successText,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            return isSelected
                                ? AppColors.successText
                                : Colors.grey;
                          },
                        ),
                      ),
                    ],
                  );
                })),
            if (state.hasError &&
                !controller.responses.containsKey(question.id))
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
