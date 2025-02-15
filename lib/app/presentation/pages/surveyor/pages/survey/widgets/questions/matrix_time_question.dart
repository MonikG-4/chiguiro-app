import 'package:flutter/material.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../matrix_cell.dart';
import '../matrix_table.dart';

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

    return MatrixTable(
      question: question,
      controller: controller,
      rows: rows,
      columns: columns,
      cellBuilder: (rowLabel, colLabel, initialValue, onChanged) => MatrixCell(
        initialValue: initialValue,
        hinText: rowLabel,
        onChanged: onChanged,
      ),
    );
  }
}