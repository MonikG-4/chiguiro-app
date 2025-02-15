import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/sections.dart';
import '../../domain/entities/survey_question.dart';
import '../../domain/repositories/i_survey_repository.dart';
import '../services/location_service.dart';
import 'auth_storage_controller.dart';

class SurveyController extends GetxController {
  final ISurveyRepository _repository;
  final LocationService _locationService = Get.find<LocationService>();
  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  // Estado de la Encuesta
  final sections = <Sections>[].obs;
  final responses = <String, dynamic>{}.obs;
  final isLoading = false.obs;

  // Variables de Control
  late bool isGeoLocation;
  late bool isVoiceRecorder;
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
      isLoading.value = true;
      final fetchedSections = await _repository.fetchSurveyQuestions(surveyId);
      fetchedSections.sort((a, b) => a.sort.compareTo(b.sort));
      sections.assignAll(fetchedSections);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Validador genérico para preguntas obligatorias
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

  Future<void> saveSurveyResults(int projectId, int pollsterId) async {
    final token = Get.find<AuthStorageController>().token;
    final position = isGeoLocation ? await _locationService.getCurrentLocation() : null;

    final entryInput = {
      'projectId': projectId,
      'answers': _buildAnswers(),
      if (isGeoLocation && position != null) ...{
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'pollsterId': pollsterId,
      if (isVoiceRecorder) 'audio': audioBase64,
      'startedOn': timeAnswerStart.value.toIso8601String(),
      'finishedOn': DateTime.now().toIso8601String(),
    };

    try {
      await _repository.saveSurveyResults(entryInput, token!);
    } catch (e) {
      _handleError(e);
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

  List<Map<String, String>> _buildMatrixTimeResults(List<dynamic> responseValue) {
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

  void _printEntryInput(Map<String, dynamic> entryInput) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(entryInput);
    const int chunkSize = 800;
    for (int i = 0; i < jsonString.length; i += chunkSize) {
      print(jsonString.substring(i, i + chunkSize > jsonString.length ? jsonString.length : i + chunkSize));
    }
  }
}
