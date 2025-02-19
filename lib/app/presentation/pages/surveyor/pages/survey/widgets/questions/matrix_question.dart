import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/values/app_colors.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';

class MatrixQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const MatrixQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  MatrixQuestionState createState() => MatrixQuestionState();
}

class MatrixQuestionState extends State<MatrixQuestion> {

  SurveyQuestion get question => widget.question;
  SurveyController get controller => widget.controller;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final List<String> subQuestions = question.meta;
    final List<String> answers = question.meta2 ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormField<List<Map<String, String>>>(
          validator: (value) {
            final responses = controller.responses[question.id]?['value'] ?? [];
            for (var subQuestion in subQuestions) {
              bool hasAnswered = responses.any((element) =>
              element.containsKey(subQuestion) && element[subQuestion] != null);
              if (!hasAnswered) {
                return 'Por favor, selecciona una respuesta para todas las subpreguntas';
              }
            }
            return null;
          },
          builder: (FormFieldState<List<Map<String, String>>> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var subIndex = 0; subIndex < subQuestions.length; subIndex++) ...[
                  Text(
                    subQuestions[subIndex],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() {
                      final selectedValues = controller.responses[question.id]?['value'] ?? [];
                      return Row(
                        children: answers.map((answer) {
                          bool isSelected = selectedValues.any((element) =>
                          element[subQuestions[subIndex]] == answer);

                          return GestureDetector(
                            onTap: () {
                              _handleAnswerSelection(subQuestions[subIndex], answer, state);
                            },
                            child: Card(
                              color: isSelected
                                  ? AppColors.successBackground
                                  : const Color(0xFFF8FAFC),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.successBorder
                                      : Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  answer,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _handleAnswerSelection(
      String subQuestion,
      String answer,
      FormFieldState<List<Map<String, String>>> state,
      ) {
    final currentResponse = controller.responses[question.id] ?? {
      'question': question.question,
      'type': question.type,
      'value': <Map<String, String>>[],
    };

    final List<Map<String, String>> currentValues =
    List<Map<String, String>>.from(currentResponse['value']);

    final index = currentValues.indexWhere((element) => element.containsKey(subQuestion));

    if (index != -1) {
      if (currentValues[index][subQuestion] == answer) {
        currentValues.removeAt(index);
      } else {
        currentValues[index][subQuestion] = answer;
      }
    } else {
      currentValues.add({subQuestion: answer});
    }

    if (currentValues.isEmpty) {
      controller.responses.remove(question.id);
    } else {
      currentResponse['value'] = currentValues;
      controller.responses[question.id] = currentResponse;
    }

    state.validate();
  }
}
