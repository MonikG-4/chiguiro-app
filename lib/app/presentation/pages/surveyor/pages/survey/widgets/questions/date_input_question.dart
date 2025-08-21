import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_select.dart';

class DateInputQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const DateInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<DateInputQuestion> createState() => _DateInputQuestionState();
}

class _DateInputQuestionState extends State<DateInputQuestion> {
  final RxnInt selectedDay = RxnInt();
  final RxnInt selectedMonth = RxnInt();
  final RxnInt selectedYear = RxnInt();

  final RxString dayText = ''.obs;
  final RxString monthText = ''.obs;
  final RxString yearText = ''.obs;

  @override
  void initState() {
    super.initState();
    final currentValue =
    widget.controller.responses[widget.question.id]?['value'];
    if (currentValue is String) {
      final selectedDate = DateFormat('dd-MM-yyyy').parse(currentValue);
      _initializeDate(selectedDate);
    } else if (currentValue is DateTime) {
      _initializeDate(currentValue);
    }
  }

  void _initializeDate(DateTime date) {
    selectedDay.value = date.day;
    selectedMonth.value = date.month;
    selectedYear.value = date.year;

    dayText.value = date.day.toString().padLeft(2, '0');
    monthText.value = getMonthName(date.month);
    yearText.value = date.year.toString();
  }

  void updateDate() {
    // Actualizar textos aunque falte alguno
    dayText.value = selectedDay.value?.toString().padLeft(2, '0') ?? '';
    monthText.value = selectedMonth.value != null ? getMonthName(selectedMonth.value!) : '';
    yearText.value = selectedYear.value?.toString() ?? '';

    // Solo si están los 3, actualiza el valor completo
    if (selectedYear.value == null ||
        selectedMonth.value == null ||
        selectedDay.value == null) return;

    int maxDays = getDaysInMonth(selectedYear.value!, selectedMonth.value!);
    if (selectedDay.value! > maxDays) {
      selectedDay.value = maxDays;
    }

    DateTime newDate = DateTime(
      selectedYear.value!,
      selectedMonth.value!,
      selectedDay.value!,
    );

    widget.controller.responses[widget.question.id] = {
      'question': widget.question.question,
      'type': widget.question.type,
      'value': newDate,
    };
    widget.controller.responses.refresh();
  }


  String getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month - 1];
  }

  int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int getMonthNumber(String monthName) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months.indexOf(monthName) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentYear = DateTime.now().year;
    final years =
    List.generate(101, (index) => (currentYear - index +5).toString());

    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    final dayKey = GlobalKey();
    final monthKey = GlobalKey();
    final yearKey = GlobalKey();

      return FormField<DateTime>(
        key: ValueKey('date_${widget.question.id}'),
        validator: widget.controller.validatorMandatory(widget.question),
        builder: (FormFieldState<DateTime> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Selector de día
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.21,
                    child: Obx(() => CustomSelect(
                      keyDropdown: dayKey,
                      value: dayText.value.isEmpty ? null : dayText.value,
                      items: List.generate(
                          getDaysInMonth(
                            selectedYear.value ?? now.year,
                            selectedMonth.value ?? now.month,
                          ),
                              (index) => (index + 1).toString().padLeft(2, '0')),

                      label: 'Día',
                      state: state,
                      onSelected: (String? value) {
                        if (value != null) {
                          selectedDay.value = int.parse(value);
                          updateDate();
                          state.didChange(widget.controller.responses[widget.question.id]?['value']);
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
                      value: monthText.value.isEmpty ? null : monthText.value,
                      items: months,
                      label: 'Mes',
                      state: state,
                      onSelected: (String? value) {
                        if (value != null) {
                          selectedMonth.value = getMonthNumber(value);
                          updateDate();
                          state.didChange(widget.controller.responses[widget.question.id]?['value']);
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
                      value: yearText.value.isEmpty ? null : yearText.value,
                      items: years,
                      label: 'Año',
                      state: state,
                      onSelected: (String? value) {
                        if (value != null) {
                          selectedYear.value = int.parse(value);
                          updateDate();
                          state.didChange(widget.controller.responses[widget.question.id]?['value']);
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
  }
}