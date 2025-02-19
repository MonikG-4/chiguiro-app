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
    final cellControllers = <String, TextEditingController>{};

  return MatrixTable(
    question: question,
    controller: controller,
    rows: rows,
    columns: columns,
    cellBuilder: (rowLabel, colLabel, initialValue, onChanged) {
      final key = '$rowLabel-$colLabel';

      if (!cellControllers.containsKey('${key}_1')) {
        final parts = initialValue.split('.');
        cellControllers['${key}_1'] = TextEditingController(text: parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : '');
        cellControllers['${key}_2'] = TextEditingController(text: parts.isNotEmpty && parts[0].length > 1 ? parts[0][1] : '');
        cellControllers['${key}_3'] = TextEditingController(text: parts.length > 1 ? parts[1] : '');
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MatrixCell(
            controller: cellControllers['${key}_1']!,
            hinText: '',
            onChanged: (v) => onChanged(
              _mergeParts(
                v,
                cellControllers['${key}_2']!.text,
                cellControllers['${key}_3']!.text,
              ),
            ),
          ),
          MatrixCell(
            controller: cellControllers['${key}_2']!,
            hinText: '',
            onChanged: (v) => onChanged(
              _mergeParts(
                cellControllers['${key}_1']!.text,
                v,
                cellControllers['${key}_3']!.text,
              ),
            ),
          ),
          const Text('.'),
          MatrixCell(
            controller: cellControllers['${key}_3']!,
            hinText: '',
            onChanged: (v) => onChanged(
              _mergeParts(
                cellControllers['${key}_1']!.text,
                cellControllers['${key}_2']!.text,
                v,
              ),
            ),
          ),
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