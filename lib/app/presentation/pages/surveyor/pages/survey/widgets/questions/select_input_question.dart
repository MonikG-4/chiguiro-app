import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_select.dart';

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
    final GlobalKey selectKey = GlobalKey(debugLabel: question.id);

    return FormField<String>(
      validator: controller.validatorMandatory(question),
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final selectedValue = controller.responses[question.id]?['value'];

              return CustomSelect(
                value: selectedValue,
                items: question.meta,
                label: 'Selecciona una opción',
                keyDropdown: selectKey,
                state: state,
                onSelected: (value) {
                  if (value == null) {
                    controller.responses.remove(question.id);
                  } else {
                    controller.responses[question.id] = {
                      'question': question.question,
                      'type': question.type,
                      'value': value,
                    };
                  }
                  state.didChange(value);
                  state.validate();
                },
              );
            }),
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
