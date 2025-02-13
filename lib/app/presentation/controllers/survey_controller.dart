import 'dart:convert';

import 'package:get/get.dart';

import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/survey_question.dart';
import '../../domain/repositories/i_survey_repository.dart';

class SurveyController extends GetxController {
  final ISurveyRepository repository;
  final questions = <SurveyQuestion>[].obs;
  var responses = <String, dynamic>{}.obs;
  var entryInput = <String, dynamic>{}.obs;
  var timeAnswerStart = ''.obs;
  final isLoading = false.obs;



  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  SurveyController(this.repository);

  @override
  void onInit() {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
    timeAnswerStart.value = DateTime.now().toString();
  }

  Future<void> fetchSurveyQuestions(int surveyId) async {
    try {
      isLoading.value = true;
      final response = await repository.fetchSurveyQuestions(surveyId);

      questions.assignAll(response);
    } catch (e) {
      message.update((val) {
        val?.message = e.toString().replaceAll("Exception:", "");
        val?.state = 'error';
      });
    } finally {
      isLoading.value = false;
    }
  }

  String? Function(dynamic value) validatorMandatory(SurveyQuestion question) {
    return (value) {
      if (question.mandatory && (value == null || value.isEmpty)) {
        return 'Este campo es obligatorio';
      }
      return null;
    };
  }

  List<Map<String, dynamic>> saveSurveyResults(int projectId) {
    List<Map<String, dynamic>> answers = [];

    responses.forEach((questionId, value) {
      Map<String, dynamic> answer = {};

      answer['questionId'] = questionId;

      String questionType = value['type'];

      switch (questionType) {
        case 'Boolean':
        case 'Radio':
        case 'Select':
        case 'String':
        case 'Integer':
        case 'Double':
        case 'Star':
        case 'Scale':
          answer['answer'] = value['value'].toString();
          break;

        case 'Check':
          if (value['value'] is List) {
            answer['checkResults'] =
                value['value'].map((item) => item.toString()).toList();
          }
          break;

        case 'Matrix':
          if (value['value'] is List) {
            List<Map<String, dynamic>> matrixResults = [];

            for (var subQuestion in value['value']) {
              subQuestion.forEach((meta, result) {
                matrixResults.add({
                  'meta': meta,
                  'result': result.toString(),
                });
              });
            }

            answer['matrixResults'] = matrixResults;
          }
          break;

        default:
          break;
      }

      answers.add(answer);
    });

    return answers;
  }

  void getSurveyResults(int projectId, int pollsterId) {
    Map<String, dynamic> entryInput = {
      'projectId': projectId,
      'answers': saveSurveyResults(projectId),
      // 'latitude': '',
      // 'longitude': '',
      'pollsterId': pollsterId,
      // 'audio': '',
      'startedOn': timeAnswerStart.value,
      'finishedOn': DateTime.now().toString()
    };

    String jsonString = JsonEncoder.withIndent('  ').convert(entryInput);

    const int chunkSize = 800; // Tamaño del fragmento
    for (int i = 0; i < jsonString.length; i += chunkSize) {
      print(jsonString.substring(
          i,
          i + chunkSize > jsonString.length
              ? jsonString.length
              : i + chunkSize));
    }
  }
}
