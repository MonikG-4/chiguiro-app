import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/sync_task_storage_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../../core/values/location.dart';
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
  final homeCode = RxnString();
  final responses = <String, dynamic>{}.obs;
  final hiddenQuestions = <String>{}.obs;
  final RxMap<int, Set<String>> jumperHiddenQuestions =
      <int, Set<String>>{}.obs;

  final isLoadingQuestion = false.obs;
  final isLoadingSendSurvey = false.obs;
  final isGeoLocation = false.obs;
  final isVoiceRecorder = false.obs;

  final Rx<File?> imageFile = Rx<File?>(null);
  final timeAnswerStart = DateTime.now().obs;

  SurveyController(this.repository);

  @override
  Future<void> onInit() async {
    super.onInit();

    _locationService = Get.find<LocationService>();
    _audioService = Get.find<AudioService>();
    _taskStorageService = Get.find<SyncTaskStorageService>();

    survey.value = Get.arguments?['survey'];
    homeCode.value = Get.arguments?['homeCode'];

    if (survey.value != null) {
      sections.assignAll(survey.value!.sections);

      final bool permissionsGranted = await _checkRequiredPermissions();
      if (!permissionsGranted) {
        Get.back();
        return;
      }

      await _loadSurveyData();
    }

    MessageHandler.setupSnackbarListener(message);
  }

  @override
  void onClose() {
    if (_audioService.isRecording.value) {
      _audioService.stopRecording();
    }
    super.onClose();
  }

  Future<bool> _checkRequiredPermissions() async {
    bool permissionsGranted = true;

    if (survey.value?.geoLocation == true) {
      final hasLocationPermission =
          await _locationService.requestLocationPermission();
      if (!hasLocationPermission) {
        _showMessage(
            'Permisos necesarios',
            'Esta encuesta requiere acceso a tu ubicación. Por favor, otorga los permisos necesarios.',
            'warning');
        permissionsGranted = false;
      }
    }

    if (survey.value?.voiceRecorder == true) {
      final hasAudioPermission = await _audioService.requestAudioPermission();
      if (!hasAudioPermission) {
        _showMessage(
            'Permisos necesarios',
            'Esta encuesta requiere acceso a tu micrófono. Por favor, otorga los permisos necesarios.',
            'warning');
        permissionsGranted = false;
      }
    }

    return permissionsGranted;
  }

  Future<void> getLocation(SurveyQuestion question) async {
    var position = _locationService.cachedPosition;
    if (position == null) {
      await _fetchLocation();
      position = _locationService.cachedPosition;
    }

    final location =
        getDepartmentAndCityFromCoords(position!.latitude, position.longitude);
    responses[question.id] = {
      'question': question.question,
      'type': question.type,
      'value': ['Colombia', '${location['department']}', '${location['city']}'],
    };
  }

  Future<void> pickImage(SurveyQuestion question) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final File file = File(pickedFile.path);

        if (responses.containsKey(question.id)) {
          if (responses[question.id]['value'] is List<File>) {
            (responses[question.id]['value'] as List<File>).add(file);
          } else {
            responses[question.id]['value'] = <File>[file];
          }
        } else {
          responses[question.id] = {
            'question': question.question,
            'type': question.type,
            'value': <File>[file],
          };
        }
        responses.refresh();
      }
    } else {
      _showMessage(
          'Camara',
          'Es necesario permitir el acceso a la cámara para tomar fotos.',
          'error');
    }
  }

  Future<void> fetchSurveys(int surveyorId) async {
    isLoadingQuestion.value = true;

    try {
      final result = await repository.fetchSurveys(surveyorId);

      result.fold((failure) {
        _showMessage('Error', _mapFailureToMessage(failure), 'error');
      }, (data) {
        surveyPending.value = data;
      });
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isLoadingQuestion.value = false;
    }
  }

  Future<void> _loadSurveyData() async {
    if (survey.value != null) {
      isGeoLocation.value = survey.value!.geoLocation;
      isVoiceRecorder.value = survey.value!.voiceRecorder;

      if (isVoiceRecorder.value) {
        await _audioService.startRecording();
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
          (question.type == 'Location' && responseValue.length < 2)) {
        return 'Esta pregunta es obligatoria';
      }

      if ((question.type == 'Matrix') && responseValue is List) {
        final subQuestions = question.meta;
        for (var subQuestion in subQuestions) {
          bool hasAnswered = responseValue.any((element) =>
              element.containsKey(subQuestion) && element[subQuestion] != null);
          if (!hasAnswered) {
            return 'Por favor, selecciona una respuesta para todas las subpreguntas';
          }
        }
      }

      if ((question.type == 'MatrixTime' || question.type == 'MatrixDouble')) {
        final subQuestions = question.meta2 ?? [];
        final subQuestions2 = question.meta;

        for (var subQuestion in subQuestions) {
          for (var subQuestion2 in subQuestions2) {
            bool hasAnswered = responseValue.any((element) =>
                element['columna'] == subQuestion &&
                element['fila'] == subQuestion2 &&
                element['respuesta'] != null);
            if (!hasAnswered) {
              return 'Por favor, selecciona una respuesta para todas las intersecciones';
            }
          }
        }
      }

      if (question.type == 'Photo' && responseValue == null) {
        return 'Debe tomar al menos una foto';
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

        result.fold((failure) {
          throw Exception(_mapFailureToMessage(failure));
        }, (data) {
          if (!data) {
            throw Exception('Fallo al enviar la encuesta al servidor');
          }

          if (entryInputPending != null) {
            _taskStorageService.removeTask(entryInputPending['id']);
          }
          _showMessage('Encuesta', 'Encuesta enviada correctamente', 'success');
        });
      } catch (e) {
        _showMessage(
            'Encuesta', e.toString().replaceAll("Exception: ", ""), 'error');
        await _saveSurveyLocally(entryInputPending, entryInput);
      }
    } catch (e) {
      _showMessage(
          'Encuesta', e.toString().replaceAll("Exception: ", ""), 'error');
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
        Get.until(
          (route) =>
              route.settings.name ==
              (entryInputPending != null
                  ? Routes.DASHBOARD_SURVEYOR
                  : Routes.SURVEY_DETAIL),
        );
      }
    }
  }

  Future<void> _saveSurveyLocally(Map<String, dynamic>? entryInputPending,
      SurveyEntryModel entryInput) async {
    await _taskStorageService.addTask(SyncTaskModel(
      id: entryInputPending?['id'] ?? generateUniqueId(),
      surveyName: entryInputPending?['surveyName'] ??
          survey.value?.name ??
          'Desconocido',
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
      homeCode: homeCode.value ?? '',
      projectId: projectId,
      pollsterId: pollsterId,
      audio: audioBase64,
      answers: await _buildAnswers(),
      latitude: _locationService.cachedPosition?.latitude.toString(),
      longitude: _locationService.cachedPosition?.longitude.toString(),
      startedOn: timeAnswerStart.value.toIso8601String(),
      finishedOn: DateTime.now().toIso8601String(),
    );
  }

  Future<List<Map<String, dynamic>>> _buildAnswers() async {
    List<Map<String, dynamic>> answers = [];

    for (var entry in responses.entries) {
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

        case 'Photo':
          if (responseValue is List<File> && responseValue.isNotEmpty) {
            final bytes = await responseValue.first.readAsBytes();
            final String base64Image = base64Encode(bytes);
            answer['answer'] = base64Image;
          } else {
            answer['answer'] = null;
          }
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
      answers.add(answer);
    }

    return answers;
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

        if ((question.type == 'MatrixTime' ||
                question.type == 'MatrixDouble') &&
            question.mandatory) {
          final value = response?['value'] as List;
          final subQuestions = question.meta2 ?? [];
          final subQuestions2 = question.meta;

          if (value.length < subQuestions.length * subQuestions2.length ||
              value.any((element) => element['respuesta'] == null)) {
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

  Map<String, String> getDepartmentAndCityFromCoords(double lat, double lon) {
    final locationData = LocationData.getLocationData();

    double calculateDistance(
        double lat1, double lon1, double lat2, double lon2) {
      const earthRadius = 6371; // Radio de la Tierra en km
      final dLat = (lat2 - lat1) * (3.141592653589793 / 180);
      final dLon = (lon2 - lon1) * (3.141592653589793 / 180);
      final a = (sin(dLat / 2) * sin(dLat / 2)) +
          cos(lat1 * (3.141592653589793 / 180)) *
              cos(lat2 * (3.141592653589793 / 180)) *
              (sin(dLon / 2) * sin(dLon / 2));
      final c = 2 * atan2(sqrt(a), sqrt(1 - a));
      return earthRadius * c;
    }

    String? closestDepartment;
    String? closestCity;
    double minDistance = double.infinity;

    for (var country in locationData['countries']) {
      for (var department in country['departments']) {
        final depLat = department['latitude'];
        final depLon = department['longitude'];
        final depDistance = calculateDistance(lat, lon, depLat, depLon);

        if (depDistance < minDistance) {
          minDistance = depDistance;
          closestDepartment = department['departamento'];
        }

        for (var city in department['ciudades']) {
          final cityLat = city['latitude'];
          final cityLon = city['longitude'];
          final cityDistance = calculateDistance(lat, lon, cityLat, cityLon);

          if (cityDistance < minDistance) {
            minDistance = cityDistance;
            closestDepartment = department['departamento'];
            closestCity = city['name'];
          }
        }
      }
    }

    return {
      'department': closestDepartment ?? 'Desconocido',
      'city': closestCity ?? 'Desconocido'
    };
  }

  Future<void> printEntryInput(Map<String, dynamic> entryInput) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(entryInput);

    try {
      // Obtiene el directorio de almacenamiento externo
      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        print("No se pudo obtener el directorio externo.");
        return;
      }

      final String filePath = '${directory.path}/debug_data.json';
      final File jsonFile = File(filePath);
      await jsonFile.writeAsString(jsonString);

      print("\n=== ARCHIVO JSON GUARDADO ===");
      print("Ruta: $filePath");
    } catch (e) {
      print("\n=== ERROR AL GUARDAR ARCHIVO ===");
      print("Error: $e");
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
