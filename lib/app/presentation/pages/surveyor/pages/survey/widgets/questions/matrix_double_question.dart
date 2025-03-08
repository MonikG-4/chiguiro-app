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

        final cellController1 = TextEditingController(text: parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '');
        final cellController2 = TextEditingController(text: parts.isNotEmpty && parts[0].length > 1 ? parts[0][1] : '');
        final cellController3 = TextEditingController(text: parts.length > 1 ? parts[1] : '');

        return StatefulBuilder(
          builder: (context, setState) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MatrixCell(
                  controller: cellController1,
                  hinText: '',
                  onChanged: (v) {
                    setState(() => onChanged(_mergeParts(v, cellController2.text, cellController3.text)));
                  },
                ),
                MatrixCell(
                  controller: cellController2,
                  hinText: '',
                  onChanged: (v) {
                    setState(() => onChanged(_mergeParts(cellController1.text, v, cellController3.text)));
                  },
                ),
                const Text('.'),
                MatrixCell(
                  controller: cellController3,
                  hinText: '',
                  onChanged: (v) {
                    setState(() => onChanged(_mergeParts(cellController1.text, cellController2.text, v)));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _mergeParts(String v1, String v2, String v3) {
    final firstPart = '$v1$v2'.trim();
    final secondPart = v3.trim();

    return firstPart.isEmpty ? '0.$secondPart' : secondPart.isEmpty ? '$firstPart.0' : '$firstPart.$secondPart';
  }
}
