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

    // Creamos un mapa de controladores para las celdas
    final Map<String, TextEditingController> cellControllers = {};

    return MatrixTable(
      question: question,
      controller: controller,
      rows: rows,
      columns: columns,
      cellBuilder: (rowLabel, colLabel, initialValue, onChanged) {
        final cellKey = '$rowLabel-$colLabel';

        // Si no existe, se crea el controlador con el valor inicial
        if (!cellControllers.containsKey(cellKey)) {
          cellControllers[cellKey] = TextEditingController(text: initialValue);
        } else {
          // Si el valor en `responses` cambia, actualizamos el texto del controlador
          if (cellControllers[cellKey]!.text != initialValue) {
            cellControllers[cellKey]!.text = initialValue;
          }
        }

        return MatrixCell(
          controller: cellControllers[cellKey]!,
          hinText: rowLabel,
          onChanged: onChanged,
        );
      },
    );
  }
}
