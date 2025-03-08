import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

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
    return Obx(() {
      final currentValue = controller.responses[question.id]?['value'];

      return FormField<String>(
        key: ValueKey('date_${question.id}_${currentValue?.toString() ?? 'empty'}'),
        initialValue: currentValue != null
            ? DateFormat('dd-MM-yyyy').format(currentValue)
            : null,
        validator: controller.validatorMandatory(question),
        builder: (FormFieldState<String> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInput(
                hasError: state.hasError,
                hasValue: currentValue != null,
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: currentValue ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    locale: const Locale('es', 'ES'),
                  );

                  if (selectedDate != null) {
                    String formattedDate =
                    DateFormat('dd-MM-yyyy').format(selectedDate);

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
                      currentValue != null
                          ? DateFormat('dd-MM-yyyy').format(currentValue)
                          : 'Selecciona una fecha',
                      style: TextStyle(
                        color: currentValue != null
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
    });
  }
}