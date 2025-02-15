import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/values/app_colors.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_input.dart';

class CheckInputQuestion extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const CheckInputQuestion({
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
            ...question.meta.map<Widget>((option) {
              return Obx(() {
                final responseValue = controller.responses[question.id]?['value'];

                List<String> selectedOptions = [];
                if (responseValue != null) {
                  if (responseValue is List) {
                    selectedOptions = responseValue.map((e) => e.toString()).toList();
                  } else if (responseValue is String) {
                    selectedOptions = [responseValue];
                  }
                }

                bool isSelected = selectedOptions.contains(option.toString());

                void toggleSelection() {
                  List<String> updatedOptions = List<String>.from(selectedOptions);

                  if (isSelected) {
                    updatedOptions.remove(option.toString());
                  } else {
                    updatedOptions.add(option.toString());
                  }

                  if (updatedOptions.isEmpty) {
                    controller.responses.remove(question.id);
                  } else {
                    controller.responses[question.id] = {
                      'question': question.question,
                      'type': question.type,
                      'value': updatedOptions,
                    };
                  }

                  state.didChange(updatedOptions.join(', '));
                  state.validate();
                }

                return  CustomInput(
                  hasError: state.hasError,
                  hasValue: controller.responses[question.id] != null,
                  onTap: toggleSelection,
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
                              fontWeight: FontWeight.w600),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => toggleSelection(),
                      activeColor: AppColors.successText,
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          return isSelected ? AppColors.successText : Colors.transparent;
                        },
                      ),
                      side: WidgetStateBorderSide.resolveWith(
                            (Set<WidgetState> states) {
                          return BorderSide(
                            color: isSelected ? AppColors.successText : Colors.grey,
                          );
                        },
                      ),
                    ),
                  ],
                );
              });
            }),
            if (state.hasError)
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
