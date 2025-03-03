import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/sync_task_storage_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../../core/values/routes.dart';
import '../../data/models/survey_entry_model.dart';
import '../../data/models/sync_task_model.dart';
import '../../domain/entities/sections.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/survey_question.dart';
import '../../domain/repositories/i_survey_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/connectivity_service.dart';

class SurveyController extends GetxController {
  final ISurveyRepository _repository;
  final LocationService _locationService = Get.find<LocationService>();
  final AudioService _audioService = Get.find<AudioService>();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final SyncTaskStorageService _taskStorageService =
      Get.find<SyncTaskStorageService>();
  final LocalStorageService _localStorageService =
      Get.find<LocalStorageService>();

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  final survey = Rx<Survey?>(null);
  final sections = <Sections>[].obs;
  final responses = <String, dynamic>{}.obs;
  final hiddenQuestions = <String>{}.obs;
  final RxMap<int, Set<String>> jumperHiddenQuestions =
      <int, Set<String>>{}.obs;

  final isLoadingQuestion = false.obs;
  final isLoadingSendSurvey = false.obs;
  final isGeoLocation = false.obs;
  final isVoiceRecorder = false.obs;

  final timeAnswerStart = DateTime.now().obs;

  SurveyController(this._repository);

  @override
  void onInit() {
    super.onInit();

    survey.value = Get.arguments['survey'];
    sections.assignAll(survey.value!.sections);
    MessageHandler.setupSnackbarListener(message);
    _loadSurveyData();
  }

  @override
  void onClose() {
    if (_audioService.isRecording.value) {
      _audioService.stopRecording();
    }
    super.onClose();
  }

  void _loadSurveyData() {
    // survey.value = _localStorageService.getSurvey();
    // sections.assignAll(_localStorageService.getSections());
    //
    // if (survey.value != null) {
    //   isGeoLocation.value = survey.value!.geoLocation;
    //   isVoiceRecorder.value = survey.value!.voiceRecorder;
    //
    //   if (isVoiceRecorder.value) {
    //     _audioService.startRecording();
    //   }
    //
    //   if (isGeoLocation.value) {
    //     _fetchLocation();
    //   }
    // }
  }

  Future<void> _fetchLocation() async {
    await _locationService.initializeCachedPosition();
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

  String generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomValue = DateTime.now().microsecondsSinceEpoch.remainder(10000);
    return '$timestamp$randomValue';
  }

  Future<void> saveSurveyResults(int pollsterId) async {
    if (!validateAllQuestions()) return;
    String? audioBase64 = '';

      if (isVoiceRecorder.value && _audioService.isRecording.value) {
        audioBase64 = await _audioService.stopRecording();
      }

    isLoadingSendSurvey.value = true;

    try {
      final entryInput =
          await _createSurveyEntry(survey.value!.id, pollsterId, audioBase64!);
      //printEntryInput(entryInput.toJson());
      if (_connectivityService.isConnected.value) {
        final isSuccess =
            await _repository.saveSurveyResults(entryInput.toJson());
        if (!isSuccess) {
          _showMessage('Error enviando la encuesta al servidor', 'error');
        }
        _showMessage('Encuesta enviada correctamente', 'success');
      } else {
        await _taskStorageService.addTask(SyncTaskModel(
          id: generateUniqueId(),
          endpoint: 'saveSurvey',
          payload: entryInput.toJson(),
          repositoryKey: 'surveyRepository',
        ));
        _showMessage('Sin conexión. Encuesta guardada localmente.', 'warning');
      }
      Get.until((route) => route.settings.name == Routes.SURVEY_DETAIL);
    } catch (e) {
      _showMessage('Error al registrar la encuesta', 'error');
    } finally {
      isLoadingSendSurvey.value = false;
    }
  }

  Future<SurveyEntryModel> _createSurveyEntry(
      int projectId, int pollsterId, String audioBase64) async {
    return SurveyEntryModel(
      projectId: projectId,
      pollsterId: pollsterId,
      audio: audioBase64,
      answers: _buildAnswers(),
      latitude: _locationService.cachedPosition?.latitude.toString(),
      longitude: _locationService.cachedPosition?.longitude.toString(),
      startedOn: timeAnswerStart.value.toIso8601String(),
      finishedOn: DateTime.now().toIso8601String(),
    );
  }

  Future<void> _handleFailedSubmission(SurveyEntryModel entry) async {
    message.update((val) {
      val?.message = 'Error al enviar. Guardada localmente para reintento.';
      val?.state = 'warning';
    });
    Get.offAllNamed(Routes.DASHBOARD_SURVEYOR);
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

  void _showMessage(String msg, String state) {
    message.update((val) {
      val?.message = msg;
      val?.state = state;
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
            val?.message =
                'Por favor responde todas las preguntas obligatorias';
            val?.state = 'error';
          });
          return false;
        }

        if (question.type == 'Matrix') {
          final value = response['value'] as List;
          final subQuestions = question.meta.length;
          if (value.length < subQuestions) {
            message.update((val) {
              val?.message =
                  'Por favor responde todas las preguntas obligatorias';
              val?.state = 'error';
            });
            return false;
          }
        }
      }
    }
    return true;
  }

  void handleJumper(SurveyQuestion question, String? selectedValue) {
    final int startSort = question.sort;
    final jumper =
        question.jumpers?.firstWhereOrNull((j) => j.value == selectedValue);
    final int? endSort = jumper?.questionNumber;

    if (selectedValue == null || jumper == null) {
      _showQuestionsFromJumper(startSort);
      jumperHiddenQuestions.remove(startSort);
      _rebuildHiddenQuestions();
      return;
    }

    _hideQuestionsFromJumper(startSort, endSort!);
  }

  void _rebuildHiddenQuestions() {
    final allHiddenQuestions = <String>{};

    for (var hiddenSet in jumperHiddenQuestions.values) {
      allHiddenQuestions.addAll(hiddenSet);
    }

    hiddenQuestions.value = allHiddenQuestions;
  }

  void _hideQuestionsFromJumper(int startSort, int endSort) {
    final questionsToHide = <String>{};

    for (var section in sections) {
      for (var q in section.surveyQuestion) {
        if (q.sort > startSort && q.sort < endSort) {
          questionsToHide.add(q.id);
          responses.remove(q.id);
        }
      }
    }

    jumperHiddenQuestions[startSort] = questionsToHide;
    _rebuildHiddenQuestions();
  }

  void _showQuestionsFromJumper(int startSort) {
    jumperHiddenQuestions.remove(startSort);
    _rebuildHiddenQuestions();
  }

  void printEntryInput(Map<String, dynamic> entryInput) {
    final jsonString = const JsonEncoder.withIndent('  ').convert(
      entryInput.map((key, value) {
        if (value is DateTime) {
          return MapEntry(key, value.toIso8601String());
        } else if (value is Map) {
          return MapEntry(
              key, _convertDateTimeInMap(value.cast<String, dynamic>()));
        } else if (value is List) {
          return MapEntry(key, _convertDateTimeInList(value));
        }
        return MapEntry(key, value);
      }),
    );
    const int chunkSize = 800;
    for (int i = 0; i < jsonString.length; i += chunkSize) {
      print(jsonString.substring(
          i,
          i + chunkSize > jsonString.length
              ? jsonString.length
              : i + chunkSize));
    }
  }

  Map<String, dynamic> _convertDateTimeInMap(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      } else if (value is Map) {
        return MapEntry(
            key, _convertDateTimeInMap(value.cast<String, dynamic>()));
      } else if (value is List) {
        return MapEntry(key, _convertDateTimeInList(value));
      }
      return MapEntry(key, value);
    });
  }

  List<dynamic> _convertDateTimeInList(List<dynamic> list) {
    return list.map((value) {
      if (value is DateTime) {
        return value.toIso8601String();
      } else if (value is Map) {
        return _convertDateTimeInMap(value.cast<String, dynamic>());
      } else if (value is List) {
        return _convertDateTimeInList(value);
      }
      return value;
    }).toList();
  }
}
