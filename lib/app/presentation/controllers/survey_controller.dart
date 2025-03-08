import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/audio_service.dart';
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

class SurveyController extends GetxController {
  final ISurveyRepository repository;
  late final LocationService _locationService;
  late final AudioService _audioService;
  late final SyncTaskStorageService _taskStorageService;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  final surveyPending = <Map<String, dynamic>>[].obs;
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

  SurveyController(this.repository);

  @override
  void onInit() {
    super.onInit();

    _locationService = Get.find<LocationService>();
    _audioService = Get.find<AudioService>();
    _taskStorageService = Get.find<SyncTaskStorageService>();

    survey.value = Get.arguments?['survey'];
    if (survey.value != null) {
      sections.assignAll(survey.value!.sections);
    }

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

  Future<void> fetchSurveys(int surveyorId) async {
    isLoadingQuestion.value = true;

    try {
      final result = await repository.fetchSurveys(surveyorId);

      result.fold(
              (failure) {
            _showMessage('Error', _mapFailureToMessage(failure), 'error');
          },
              (data) {
            surveyPending.value = data;
          }
      );
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isLoadingQuestion.value = false;
    }
  }

  void _loadSurveyData() {
    if (survey.value != null) {
      isGeoLocation.value = survey.value!.geoLocation;
      isVoiceRecorder.value = survey.value!.voiceRecorder;

      if (isVoiceRecorder.value) {
        _audioService.startRecording();
      }

      if (isGeoLocation.value) {
        _fetchLocation();
      }
    }
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

  Future<void> saveSurveyResults(
      [int? pollsterId, Map<String, dynamic>? entryInputPending]) async {
    isLoadingSendSurvey.value = true;

    try {
      String? audioBase64 = '';

      if (entryInputPending == null) {
        if (!validateAllQuestions()) {
          isLoadingSendSurvey.value = false;
          return;
        }

        if (isVoiceRecorder.value && _audioService.isRecording.value) {
          audioBase64 = await _audioService.stopRecording();
        }
      }

      final entryInput = entryInputPending != null
          ? entryInputPending['payload'] as SurveyEntryModel
          : await _createSurveyEntry(
        survey.value!.id,
        pollsterId!,
        audioBase64,
      );

      //printEntryInput(entryInput.toJson());

      try {
        final result = await repository.saveSurveyResults(entryInput.toJson());

        result.fold(
                (failure) {
              throw Exception(_mapFailureToMessage(failure));
            },
                (data) {
              if (!data) {
                throw Exception('Fallo al enviar la encuesta al servidor');
              }

              if (entryInputPending != null) {
                _taskStorageService.removeTask(entryInputPending['id']);
              }
              _showMessage('Encuesta', 'Encuesta enviada correctamente', 'success');
            }
        );


      } catch (e) {
        await _saveSurveyLocally(entryInputPending, entryInput);
      }
    } catch (e) {
      await _saveSurveyLocally(
          entryInputPending, entryInputPending?['payload'] ?? {});
    } finally {
      isLoadingSendSurvey.value = false;
      if (survey.value?.entriesCount == 0) {
        Get.offNamedUntil(
          Routes.SURVEY_DETAIL,
              (route) => route.settings.name != Routes.SURVEY,
          arguments: {'survey': survey.value},
        );
      } else {
        // Si tiene encuestas, regresa normalmente al Dashboard
        Get.until(
              (route) => route.settings.name == (entryInputPending != null
              ? Routes.DASHBOARD_SURVEYOR
              : Routes.SURVEY_DETAIL),
        );      }

    }
  }

  Future<void> _saveSurveyLocally(
      Map<String, dynamic>? entryInputPending,
      SurveyEntryModel entryInput) async {
    await _taskStorageService.addTask(SyncTaskModel(
      id: entryInputPending?['id'] ?? generateUniqueId(),
      endpoint:
      entryInputPending?['endpoint'] ?? survey.value?.name ?? 'Desconocido',
      payload: entryInput,
      repositoryKey: 'surveyRepository',
    ));
    _showMessage(
        'Encuesta',
        'Encuesta guardada localmente, por favor verificar en ENCUESTAS PENDIENTES.',
        'info');
  }

  Future<SurveyEntryModel> _createSurveyEntry(
      int projectId, int pollsterId, String? audioBase64) async {
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

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return failure.message;
      case NetworkFailure _:
        return 'Sin conexión a internet. Verifica tu conexión.';
      case CacheFailure _:
        return 'No hay datos almacenados. Conecta a internet para obtener datos.';
      default:
        return failure.message;
    }
  }

  void _showMessage(String title, String msg, String state) {
    message.update((val) {
      val?.title = title;
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

        if (question.mandatory && response == null) {
          _showMessage('Error',
              'Por favor responde todas las preguntas obligatorias', 'error');
          return false;
        }

        if (question.type == 'Matrix' && question.mandatory) {
          final value = response?['value'] as List?;
          final subQuestions = question.meta.length;
          if (value == null || value.length < subQuestions) {
            _showMessage('Error',
                'Por favor responde todas las preguntas obligatorias', 'error');
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