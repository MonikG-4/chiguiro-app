import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_select.dart';

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
    final GlobalKey dayKey = GlobalKey();
    final GlobalKey monthKey = GlobalKey();
    final GlobalKey yearKey = GlobalKey();

    return Obx(() {
      final currentValue = controller.responses[question.id]?['value'];
      final DateTime now = DateTime.now();

      DateTime selectedDate;
      if (currentValue is String) {
        selectedDate = DateFormat('dd-MM-yyyy').parse(currentValue);
      } else if (currentValue is DateTime) {
        selectedDate = currentValue;
      } else {
        selectedDate = now;
      }

      final RxInt selectedDay = selectedDate.day.obs;
      final RxInt selectedMonth = selectedDate.month.obs;
      final RxInt selectedYear = selectedDate.year.obs;

      final RxString dayText = selectedDay.value.toString().padLeft(2, '0').obs;
      final RxString monthText = getMonthName(selectedMonth.value).obs;
      final RxString yearText = selectedYear.value.toString().obs;

      int getDaysInMonth(int year, int month) {
        return DateTime(year, month + 1, 0).day;
      }

      final List<String> months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];

final List<String> years = List.generate(DateTime.now().year - 1900 + 2, (index) => (1900 + index).toString());
      void updateDate() {
        int maxDays = getDaysInMonth(selectedYear.value, selectedMonth.value);
        if (selectedDay.value > maxDays) {
          selectedDay.value = maxDays;
        }

        DateTime newDate = DateTime(
          selectedYear.value,
          selectedMonth.value,
          selectedDay.value,
        );

        // Actualizar textos
        dayText.value = newDate.day.toString().padLeft(2, '0');
        monthText.value = getMonthName(newDate.month);
        yearText.value = newDate.year.toString();

        controller.responses[question.id] = {
          'question': question.question,
          'type': question.type,
          'value': newDate,
        };
        controller.responses.refresh();
      }

      return FormField<DateTime>(
        key: ValueKey('date_${question.id}_${currentValue?.toString() ?? 'empty'}'),
        initialValue: selectedDate,
        validator: controller.validatorMandatory(question),
        builder: (FormFieldState<DateTime> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Selector de día
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.20,
                    child: Obx(() => CustomSelect(
                      keyDropdown: dayKey,
                      value: dayText.value,
                      items: List.generate(
                          getDaysInMonth(selectedYear.value, selectedMonth.value),
                              (index) => (index + 1).toString().padLeft(2, '0')),
                      label: 'Día',
                      state: state,
                      onSelected: (String? value) {
                        if (value != null) {
                          selectedDay.value = int.parse(value);
                          updateDate();
                          state.didChange(controller.responses[question.id]?['value']);
                          state.validate();
                        }
                      },
                    )),
                  ),
                  const SizedBox(width: 8),

                  // Selector de mes
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: Obx(() => CustomSelect(
                      keyDropdown: monthKey,
                      value: monthText.value,
                      items: months,
                      label: 'Mes',
                      state: state,
                      onSelected: (String? value) {
                        if (value != null) {
                          selectedMonth.value = getMonthNumber(value);
                          updateDate();
                          state.didChange(controller.responses[question.id]?['value']);
                          state.validate();
                        }
                      },
                    )),
                  ),
                  const SizedBox(width: 8),

                  // Selector de año
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.26,
                    child: Obx(() => CustomSelect(
                      keyDropdown: yearKey,
                      value: yearText.value,
                      items: years,
                      label: 'Año',
                      state: state,
                      onSelected: (String? value) {
                        if (value != null) {
                          selectedYear.value = int.parse(value);
                          updateDate();
                          state.didChange(controller.responses[question.id]?['value']);
                          state.validate();
                        }
                      },
                    )),
                  ),
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

  String getMonthName(int month) {
    final List<String> months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  int getMonthNumber(String monthName) {
    final List<String> months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months.indexOf(monthName) + 1;
  }
}
