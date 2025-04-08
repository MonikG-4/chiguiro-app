import 'package:flutter/material.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_select.dart';
import '../matrix_table.dart';

class MatrixDoubleQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const MatrixDoubleQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<MatrixDoubleQuestion> createState() => _MatrixDoubleQuestionState();
}

class _MatrixDoubleQuestionState extends State<MatrixDoubleQuestion> {
  late List<String> rows;
  late List<String> columns;
  final Map<String, GlobalKey> dropdownKeys = {};
  final Map<String, GlobalKey<FormFieldState>> formFieldKeys = {};

  @override
  void initState() {
    super.initState();
    rows = widget.question.meta;
    columns = widget.question.meta2 ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return MatrixTable(
      question: widget.question,
      controller: widget.controller,
      rows: rows,
      columns: columns,
      cellBuilder: (rowLabel, colLabel, initialValue, onChanged) {
        final cellKey = '$rowLabel-$colLabel';
        final parts = initialValue.split('.');

        String value1 =
            (parts.isNotEmpty && parts[0].isNotEmpty) ? parts[0][0] : '';
        String value2 =
            (parts.isNotEmpty && parts[0].length > 1) ? parts[0][1] : '';
        String value3 =
            (parts.length > 1 && parts[1].isNotEmpty) ? parts[1] : '';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCustomSelect(
              cellKey: '$cellKey-1',
              initialValue: value1,
              onChanged: (newValue) {
                value1 = newValue;
                onChanged(_mergeParts(value1, value2, value3));
              },
              label: '#',
            ),
            _buildCustomSelect(
              cellKey: '$cellKey-2',
              initialValue: value2,
              onChanged: (newValue) {
                value2 = newValue;
                onChanged(_mergeParts(value1, value2, value3));
              },
              label: '#',
            ),
            const Text('.'),
            _buildCustomSelect(
              cellKey: '$cellKey-3',
              initialValue: value3,
              onChanged: (newValue) {
                value3 = newValue;
                onChanged(_mergeParts(value1, value2, value3));
              },
              label: '#',
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomSelect({
    required String cellKey,
    required String initialValue,
    required ValueChanged<String> onChanged,
    required String label,
  }) {
    final uniqueKey = Key(cellKey);
    if (!dropdownKeys.containsKey(cellKey)) {
      dropdownKeys[cellKey] = GlobalKey();
    }
    if (!formFieldKeys.containsKey(cellKey)) {
      formFieldKeys[cellKey] = GlobalKey<FormFieldState>();
    }
    return FormField<String>(
      key: uniqueKey,
      initialValue: initialValue,
      validator: (_) => null,
      builder: (FormFieldState<String> state) {
        return Flexible(
            child: CustomSelect(
          keyDropdown: dropdownKeys[cellKey] ?? GlobalKey(), // Changed here
          value: initialValue.isEmpty ? null : initialValue,
          items: List.generate(10, (index) => index.toString()),
          label: label,
          state: state,
          onSelected: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            } else {
              onChanged('0');
            }
          },
        ));
      },
    );
  }

  String _mergeParts(String v1, String v2, String v3) {
    final firstPart = '$v1$v2'.trim();
    final secondPart = v3.trim();

    return firstPart.isEmpty
        ? '0.$secondPart'
        : secondPart.isEmpty
            ? '$firstPart.0'
            : '$firstPart.$secondPart';
  }
}
