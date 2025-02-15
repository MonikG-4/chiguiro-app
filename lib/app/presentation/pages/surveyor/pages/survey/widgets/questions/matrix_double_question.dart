import 'package:flutter/material.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../matrix_cell.dart';
import '../matrix_table.dart';

class MatrixDoubleQuestion extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const MatrixDoubleQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final rows = question.meta;
    final columns = question.meta2 ?? [];

    return MatrixTable(
      question: question,
      controller: controller,
      rows: rows,
      columns: columns,
      cellBuilder: (rowLabel, colLabel, initialValue, onChanged) {
        final parts = initialValue.split('.');
        final value1 = parts.isNotEmpty ? (parts[0].isNotEmpty ? parts[0][0] : '') : '';
        final value2 = parts.isNotEmpty && parts[0].length > 1 ? parts[0][1] : '';
        final value3 = parts.length > 1 ? parts[1] : '';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MatrixCell(initialValue: value1, hinText: '', onChanged: (v) => onChanged(_mergeParts(v, value2, value3))),
            MatrixCell(initialValue: value2, hinText: '', onChanged: (v) => onChanged(_mergeParts(value1, v, value3))),
            const Text('.'),
            MatrixCell(initialValue: value3, hinText: '', onChanged: (v) => onChanged(_mergeParts(value1, value2, v))),
          ],
        );
      },
    );
  }

  String _mergeParts(String v1, String v2, String v3) {
    final firstPart = '$v1$v2'.trim();
    final secondPart = v3.trim();
    return secondPart.isEmpty ? firstPart : '$firstPart.$secondPart';
  }
}