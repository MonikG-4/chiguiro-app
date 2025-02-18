import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../../core/values/routes.dart';
import '../../domain/entities/sections.dart';
import '../../domain/entities/survey_question.dart';
import '../../domain/repositories/i_survey_repository.dart';
import '../services/location_service.dart';

class SurveyController extends GetxController {
  final ISurveyRepository _repository;
  final LocationService _locationService = Get.find<LocationService>();
  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  final sections = <Sections>[].obs;
  final responses = <String, dynamic>{}.obs;
  final hiddenQuestions = <String>{}.obs;

  final isLoadingQuestion = false.obs;
  final isLoadingSendSurvey = false.obs;

  final isGeoLocation  = false.obs;
  final isVoiceRecorder  = false.obs;

  String? audioBase64;
  final timeAnswerStart = DateTime.now().obs;

  SurveyController(this._repository);

  @override
  void onInit() {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
  }

  set setAudioBase64(String? value) => audioBase64 = value;

  Future<void> fetchSurveyQuestions(int surveyId) async {
    try {
      isLoadingQuestion.value = true;
      final fetchedSections = await _repository.fetchSurveyQuestions(surveyId);
      fetchedSections.sort((a, b) => a.sort.compareTo(b.sort));
      sections.assignAll(fetchedSections);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingQuestion.value = false;
    }
  }

  String? Function(dynamic value) validatorMandatory(SurveyQuestion question) {
    return (value) {
      if (!question.mandatory) return null;

      final responseValue = responses[question.id]?['value'];

      if (responseValue == null ||
          (responseValue is String && responseValue.isEmpty) ||
          (responseValue is List && responseValue.isEmpty) ||
          (question.type == 'Location' && responseValue.length < 3)) {
        return 'Esta pregunta es obligatoria';
      }

      return null;
    };
  }

  Future<void> saveSurveyResults({
    required int projectId,
    required int pollsterId,
    String? audioBase64,
  }) async {

    isLoadingSendSurvey.value = true;
    final position =
    isGeoLocation.value ? await _locationService.getCurrentLocation() : null;

    final entryInput = {

      'projectId': projectId,
      'pollsterId': pollsterId,
      'answers': _buildAnswers(),
      if (isGeoLocation.value && position != null) ...{
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      },
      if (isVoiceRecorder.value) 'audio': audioBase64,
      'startedOn': timeAnswerStart.value.toIso8601String(),
      'finishedOn': DateTime.now().toIso8601String(),
    };

    try {
      final isSuccess = await _repository.saveSurveyResults(entryInput);
      if (isSuccess) {
        message.update((val) {
          val?.message =
          'Encuesta enviada, tus respuestas han sido enviadas correctamente';
          val?.state = 'success';
        });

        Get.offAllNamed(Routes.DASHBOARD_SURVEYOR);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingSendSurvey.value = false;
    }

    _printEntryInput(entryInput);
  }


  List<Map<String, dynamic>> _buildAnswers() {
    return responses.entries.map((entry) {
      final questionId = int.parse(entry.key);
      final responseValue = entry.value['value'];
      final questionType = entry.value['type'];

      final Map<String, dynamic> answer = {'questionId': questionId};

      switch (questionType) {
        case 'Boolean':
        case 'Radio':
        case 'Select':
        case 'String':
        case 'Integer':
        case 'Double':
        case 'Star':
        case 'Scale':
          answer['answer'] = responseValue.toString();
          break;

        case 'Check':
        case 'Location':
          answer['checkResults'] = List<String>.from(responseValue);
          break;

        case 'Date':
          answer['dateAnswer'] = DateFormat('yyyy-MM-dd').format(responseValue);
          break;

        case 'Matrix':
          answer['matrixResults'] = _buildMatrixResults(responseValue);
          break;

        case 'MatrixTime':
        case 'MatrixDouble':
          answer['matrixResults'] = _buildMatrixTimeResults(responseValue);
          break;
      }

      return answer;
    }).toList();
  }

  List<Map<String, String>> _buildMatrixResults(List<dynamic> responseValue) {
    final matrixResults = <Map<String, String>>[];

    for (var subQuestion in responseValue) {
      subQuestion.forEach((meta, result) {
        matrixResults.add({'meta': meta, 'result': result.toString()});
      });
    }

    return matrixResults;
  }

  List<Map<String, String>> _buildMatrixTimeResults(
      List<dynamic> responseValue) {
    return responseValue
        .map<Map<String, String>>((subQuestion) => {
              'meta2': subQuestion['columna'],
              'meta': subQuestion['fila'],
              'result': subQuestion['respuesta'].toString(),
            })
        .toList();
  }

  void _handleError(Object e) {
    message.update((val) {
      val?.message = e.toString().replaceAll("Exception:", "");
      val?.state = 'error';
    });
  }

  bool validateAllQuestions() {
    for (var section in sections) {
      for (var question in section.surveyQuestion) {
        if (hiddenQuestions.contains(question.id)) {
          continue;
        }

        final response = responses[question.id];

        if (response == null) {
          message.update((val) {
            val?.message = 'Por favor responde todas las preguntas obligatorias';
            val?.state = 'error';
          });
          return false;
        }

        if (question.type == 'Matrix') {
          final value = response['value'] as List;
          final subQuestions = question.meta.length;
          if (value.length < subQuestions) {
            message.update((val) {
              val?.message = 'Por favor responde todas las preguntas obligatorias';
              val?.state = 'error';
            });
            return false;
          }
        }
      }
    }
    return true;
  }


  void handleJumper(SurveyQuestion question, String selectedValue) {
    final jumper = question.jumpers?.firstWhereOrNull((j) => j.value == selectedValue);

    final startSort = question.sort;
    final endSort = jumper?.questionNumber ?? double.infinity;

    final questionsToHide = <String>{};

    for (var section in sections) {
      for (var q in section.surveyQuestion) {
        if (q.sort > startSort && q.sort < endSort) {
          questionsToHide.add(q.id);
          responses.remove(q.id);
        }
      }
    }

    if (jumper != null) {
      // Si el jumper es válido, ocultamos las preguntas
      hiddenQuestions.addAll(questionsToHide);
    } else {
      // Si cambió la respuesta y no es un jumper, mostramos las preguntas ocultas por este bloque
      for (var section in sections) {
        for (var q in section.surveyQuestion) {
          if (q.sort > startSort && hiddenQuestions.contains(q.id)) {
            hiddenQuestions.remove(q.id);
          }
        }
      }
    }
  }


  void _printEntryInput(Map<String, dynamic> entryInput) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(entryInput);
    const int chunkSize = 800;
    for (int i = 0; i < jsonString.length; i += chunkSize) {
      print(jsonString.substring(
          i,
          i + chunkSize > jsonString.length
              ? jsonString.length
              : i + chunkSize));
    }
  }
}
