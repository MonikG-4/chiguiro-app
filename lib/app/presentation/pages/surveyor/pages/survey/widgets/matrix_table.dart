import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../domain/entities/survey_question.dart';
import '../../../../../controllers/survey_controller.dart';

class MatrixTable extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;
  final List<String> rows;
  final List<String> columns;
  final Widget Function(String row, String col, String initialValue,
      Function(String) onChanged) cellBuilder;

  const MatrixTable({
    super.key,
    required this.question,
    required this.controller,
    required this.rows,
    required this.columns,
    required this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<List<Map<String, String>>>(
      validator: controller.validatorMandatory(question),
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() {
              final responses = controller.responses[question.id]?['value']
                      as List<Map<String, String>>? ??
                  [];

              return Table(
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  _buildHeader(),
                  ...rows
                      .map((row) => _buildRow(row, columns, responses, state)),
                ],
              );
            }),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                state.errorText ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  TableRow _buildHeader() {
    return TableRow(
      children: [
        const SizedBox(width: 90),
        ...columns.map((col) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(col,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            )),
      ],
    );
  }

  TableRow _buildRow(
      String row,
      List<String> columns,
      List<Map<String, String>> responses,
      FormFieldState<List<Map<String, String>>> state) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(
            row,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),

        ...columns.map((col) {
          final initialValue = _getCellValue(responses, col, row);
          return TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              key: Key('cell${question.id}_${row}_${col}_$initialValue'),
              padding: const EdgeInsets.all(4.0),
              child: cellBuilder(row, col, initialValue,
                  (value) => _updateResponse(col, row, value, state)),
            ),
          );
        }),
      ],
    );
  }

  String _getCellValue(
      List<Map<String, String>> responses, String col, String row) {
    return responses.firstWhere(
          (e) => e['columna'] == col && e['fila'] == row,
          orElse: () => {},
        )['respuesta'] ??
        '';
  }

  void _updateResponse(String col, String row, String value,
      FormFieldState<List<Map<String, String>>> state) {
    final currentResponse = controller.responses[question.id] ??
        {
          'question': question.question,
          'type': question.type,
          'value': <Map<String, String>>[]
        };
    final List<Map<String, String>> currentValues =
        List<Map<String, String>>.from(currentResponse['value']);

    final index = currentValues
        .indexWhere((e) => e['columna'] == col && e['fila'] == row);

    if (index != -1) {
      if (value.isEmpty) {
        currentValues.removeAt(index);
      } else {
        currentValues[index]['respuesta'] = value;
      }
    } else if (value.isNotEmpty) {
      currentValues.add({'columna': col, 'fila': row, 'respuesta': value});
    }

    if (currentValues.isEmpty) {
      controller.responses.remove(question.id);
    } else {
      currentResponse['value'] = currentValues;
      controller.responses[question.id] =
          Map<String, dynamic>.from(currentResponse);
    }

    state.didChange(currentValues);
    state.validate();

    controller.update(['matrix_${question.id}']);
  }
}
