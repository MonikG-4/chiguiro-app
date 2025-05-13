import 'package:flutter/material.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../matrix_table.dart';
import '../custom_select.dart';

class MatrixTimeQuestion extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const MatrixTimeQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final rows = question.meta;
    final columns = question.meta2 ?? [];

    final Map<String, GlobalKey> dropdownKeys = {};
    final Map<String, GlobalKey<FormFieldState>> formFieldKeys = {};

    return MatrixTable(
      question: question,
      controller: controller,
      rows: rows,
      columns: columns,
      cellBuilder: (rowLabel, colLabel, initialValue, onChanged) {
        final cellKey = '$rowLabel-$colLabel';

        final uniqueKey = Key('$cellKey-$initialValue');

        if (!dropdownKeys.containsKey(cellKey)) {
          dropdownKeys[cellKey] = GlobalKey();
        }
        if (!formFieldKeys.containsKey(cellKey)) {
          formFieldKeys[cellKey] = GlobalKey<FormFieldState>();
        }

        List<String> options = [];

        if (rowLabel.toLowerCase().contains('segundo')) {
          options = List.generate(60, (i) => i.toString().padLeft(2, '0'));
        } else if (rowLabel.toLowerCase().contains('minuto')) {
          options = List.generate(60, (i) => i.toString().padLeft(2, '0'));
        } else if (rowLabel.toLowerCase().contains('hora')) {
          options = List.generate(24, (i) => i.toString().padLeft(2, '0'));
        } else {
          options = List.generate(60, (i) => i.toString().padLeft(2, '0'));
        }

        return FormField<String>(
          key: uniqueKey,
          initialValue: initialValue,
          validator: (_) => null,
          builder: (FormFieldState<String> state) {
            return CustomSelect(
              keyDropdown: dropdownKeys[cellKey]!,
              value: initialValue.isEmpty ? null : initialValue,
              items: options,
              label: rowLabel,
              state: state,
              onSelected: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                } else {
                  onChanged('');
                }
              },
            );
          },
        );
      },
    );
  }
}