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
    final currentValue = widget.controller.responses[widget.question.id]?['value'];
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
    dayText.value = selectedDay.value?.toString().padLeft(2, '0') ?? '';
    monthText.value =
    selectedMonth.value != null ? getMonthName(selectedMonth.value!) : '';
    yearText.value = selectedYear.value?.toString() ?? '';

    if (selectedYear.value == null ||
        selectedMonth.value == null ||
        selectedDay.value == null) return;

    int maxDays = getDaysInMonth(selectedYear.value!, selectedMonth.value!);
    if (selectedDay.value! > maxDays) {
      selectedDay.value = maxDays;
      dayText.value = selectedDay.value!.toString().padLeft(2, '0');
    }

    final newDate = DateTime(
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

  String? _dayValue() => dayText.value.isEmpty ? null : dayText.value;
  String? _monthValue() => monthText.value.isEmpty ? null : monthText.value;
  String? _yearValue() => yearText.value.isEmpty ? null : yearText.value;

  List<String> _dayItems(DateTime now) => List.generate(
    getDaysInMonth(
      selectedYear.value ?? now.year,
      selectedMonth.value ?? now.month,
    ),
        (i) => (i + 1).toString().padLeft(2, '0'),
  );

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentYear = now.year;
    final years = List.generate(101, (i) => (currentYear - i + 5).toString());

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

    final dayKey = GlobalKey();
    final monthKey = GlobalKey();
    final yearKey = GlobalKey();

    return FormField<DateTime>(
      key: ValueKey('date_${widget.question.id}'),
      validator: widget.controller.validatorMandatory(widget.question),
      builder: (FormFieldState<DateTime> state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final dayWidth = totalWidth * 0.26;
            final monthWidth = totalWidth * 0.39;
            final yearWidth = totalWidth * 0.30;

            Widget slot({
              required String label,
              required GlobalKey keyDropdown,
              required String? Function() getValue,
              required List<String> Function() getItems,
              required ValueChanged<String?> onSelected,
              required double width,
            }) {
              return SizedBox(
                width: width,
                child: Obx(() {
                  final v = getValue();
                  final items = getItems();
                  return CustomSelect(
                    keyDropdown: keyDropdown,
                    value: (v == null || v.isEmpty) ? null : v,
                    items: items,
                    label: label,
                    state: state,
                    onSelected: onSelected,
                  );
                }),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    slot(
                      label: 'Día',
                      keyDropdown: dayKey,
                      getValue: _dayValue,
                      getItems: () => _dayItems(now),
                      onSelected: (val) {
                        if (val != null) {
                          selectedDay.value = int.parse(val);
                          updateDate();
                          state.didChange(widget
                              .controller.responses[widget.question.id]?['value']);
                          state.validate();
                        }
                      },
                      width: dayWidth,
                    ),
                    const SizedBox(width: 6),
                    slot(
                      label: 'Mes',
                      keyDropdown: monthKey,
                      getValue: _monthValue,
                      getItems: () => months,
                      onSelected: (val) {
                        if (val != null) {
                          selectedMonth.value = getMonthNumber(val);
                          updateDate();
                          state.didChange(widget
                              .controller.responses[widget.question.id]?['value']);
                          state.validate();
                        }
                      },
                      width: monthWidth,
                    ),
                    const SizedBox(width: 6),
                    slot(
                      label: 'Año',
                      keyDropdown: yearKey,
                      getValue: _yearValue,
                      getItems: () => years,
                      onSelected: (val) {
                        if (val != null) {
                          selectedYear.value = int.parse(val);
                          updateDate();
                          state.didChange(widget
                              .controller.responses[widget.question.id]?['value']);
                          state.validate();
                        }
                      },
                      width: yearWidth,
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
      },
    );
  }
}
