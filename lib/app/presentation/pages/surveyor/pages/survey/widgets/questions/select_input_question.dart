import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/values/app_colors.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';

class SelectInputQuestion extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const SelectInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey uniqueKey = GlobalKey(debugLabel: question.id);

    return FormField<String>(
      validator: controller.validatorMandatory(question),
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              key: uniqueKey,
              onTap: () async {
                final RenderBox renderBox = uniqueKey.currentContext!.findRenderObject() as RenderBox;
                final Offset offset = renderBox.localToGlobal(Offset.zero);

                final selectedValue = await showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    offset.dx,
                    offset.dy + renderBox.size.height,
                    offset.dx + renderBox.size.width,
                    offset.dy + renderBox.size.height + 200,
                  ),
                  color: Colors.white,
                  items: [
                    ...question.meta.map(
                          (option) => PopupMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                  constraints: BoxConstraints(
                    minWidth: renderBox.size.width,
                    maxWidth: renderBox.size.width,
                  ),
                );

                if (selectedValue != null) {
                  final currentValue = controller.responses[question.id]?['value'];

                  if (currentValue == selectedValue) {
                    controller.responses.remove(question.id);
                  } else {
                    controller.responses[question.id] = {
                      'question': question.question,
                      'type': question.type,
                      'value': selectedValue,
                    };
                  }
                  state.didChange(controller.responses[question.id]?['value']);
                  state.validate();
                }
              },
              child: Obx(() {
                final selectedValue = controller.responses[question.id]?['value'];
                final bool hasValue = selectedValue != null;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: hasValue ? AppColors.successBorder : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedValue ?? 'Selecciona una opción',
                        style: TextStyle(
                          color: hasValue ? Colors.black : Colors.grey,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                );
              }),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }
}
