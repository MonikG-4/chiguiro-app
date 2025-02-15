import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_input.dart';

class DateInputQuestion extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const DateInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: controller.validatorMandatory(question),
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomInput(
              hasError: state.hasError,
              hasValue: controller.responses[question.id] != null,
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );

                if (selectedDate != null) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(selectedDate);
                  controller.responses[question.id] = {
                    'question': question.question,
                    'type': question.type,
                    'value': selectedDate,
                  };
                  controller.responses.refresh();
                  state.didChange(formattedDate);
                  state.validate();
                }
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    controller.responses[question.id]?['value'] != null
                        ? DateFormat('yyyy-MM-dd')
                            .format(controller.responses[question.id]?['value'])
                        : 'Selecciona una fecha',
                    style: TextStyle(
                      color: controller.responses[question.id] != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today),
              ],
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
