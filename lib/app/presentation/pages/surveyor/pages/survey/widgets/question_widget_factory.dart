import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../domain/entities/survey_question.dart';
import '../../../../../controllers/survey_controller.dart';
import 'questions/date_input_question.dart';
import 'questions/location_input_question.dart';
import 'questions/check_input_question.dart';
import 'questions/decimal_input_question.dart';
import 'questions/integer_input_question.dart';
import 'questions/matrix_double_question.dart';
import 'questions/matrix_question.dart';
import 'questions/matrix_time_question.dart';
import 'questions/radio_input_question.dart';
import 'questions/scale_question.dart';
import 'questions/select_input_question.dart';
import 'questions/star_rating_question.dart';
import 'questions/string_input_question.dart';

class QuestionWidgetFactory {
  static Widget createQuestionWidget(SurveyQuestion question) {
    final controller = Get.find<SurveyController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _QuestionHeader(question: question),
        const SizedBox(height: 8),
        _QuestionBody(question: question, controller: controller),
      ],
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  final SurveyQuestion question;

  const _QuestionHeader({required this.question});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              if (question.mandatory)
                const TextSpan(
                  text: '* ',
                  style: TextStyle(color: Colors.red),
                ),
              TextSpan(
                text: 'Pregunta ${question.sort}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(question.question,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        if (question.description != null) ...[
          const SizedBox(height: 12),
          Text(question.description!),
        ],
      ],
    );
  }
}

class _QuestionBody extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const _QuestionBody({required this.question, required this.controller});

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case 'Date':
        return DateInputQuestion(question: question, controller: controller);
      case 'String':
        return StringInputQuestion(question: question, controller: controller);
      case 'Select':
        return SelectInputQuestion(question: question, controller: controller);
      case 'Location':
        return LocationInputQuestion(
            question: question, controller: controller);
      case 'Integer':
        return IntegerInputQuestion(question: question, controller: controller);
      case 'Double':
        return DecimalInputQuestion(question: question, controller: controller);
      case 'Check':
        return CheckInputQuestion(question: question, controller: controller);
      case 'Boolean':
      case 'Radio':
        return RadioInputQuestion(question: question, controller: controller);
      case 'Star':
        return StarRatingQuestion(question: question, controller: controller);
      case 'Scale':
        return ScaleQuestion(question: question, controller: controller);
      case 'Matrix':
        return MatrixQuestion(question: question, controller: controller);
      case 'MatrixTime':
        return MatrixTimeQuestion(question: question, controller: controller);
      case 'MatrixDouble':
        return MatrixDoubleQuestion(question: question, controller: controller);
      default:
        return const SizedBox.shrink();
    }
  }
}
