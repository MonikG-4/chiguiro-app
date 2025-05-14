import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
    await _fetchLocation();

    var position = _locationService.cachedPosition;

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

  Future<void> saveLocalSurvey(int surveyorId) async {
    isLoadingSendSurvey.value = true;
    String? audioBase64 = '';

    if (!validateAllQuestions()) {
      isLoadingSendSurvey.value = false;
      return;
    }

    if (isVoiceRecorder.value && _audioService.isRecording.value) {
      audioBase64 = await _audioService.stopRecording();
    }

    final entryInput = await _createSurveyEntry(
      survey.value!.id,
      surveyorId,
      audioBase64,
    );

    try {
      String taskId = await _saveSurveyLocally(entryInput);
      await saveSurveyResults(entryInput, taskId: taskId);
    } catch (e) {
      _showMessage(
          'Encuesta', e.toString().replaceAll("Exception: ", ""), 'error');
    } finally {
      isLoadingSendSurvey.value = false;
    }
  }

  Future<void> saveSurveyResults(dynamic entryInput, {String? taskId}) async {
    isLoadingSendSurvey.value = true;

    try {
      late Map<String, dynamic> payload;

      if (entryInput is Map<String, dynamic>) {
        if (entryInput.containsKey('payload') && entryInput.containsKey('id')) {
          payload = entryInput['payload'].toJson();
          taskId = entryInput['id'];
        } else {
          throw Exception("Map de entrada inválido: falta 'payload' o 'id'");
        }
      } else if (entryInput is SurveyEntryModel) {
        payload = entryInput.toJson();
      } else {
        throw Exception("Tipo de entrada no válido para guardar resultados");
      }

      final result = await repository.saveSurveyResults(payload);

      if (result['data'] == null || result['data']['entry'] == null) {
        _showMessage('Encuesta', 'Encuesta guardada localmente.', 'success');
      }

      if (taskId != null) {
        await _taskStorageService.removeTask(taskId);
      }

      _showMessage('Encuesta', 'Encuesta enviada correctamente', 'success');

    } catch (e) {
      _showMessage('Encuesta', 'Encuesta guardada localmente.', 'success');
    } finally {
      isLoadingSendSurvey.value = false;
      Get.until(
            (route) => route.settings.name == Routes.DASHBOARD_SURVEYOR,
      );
    }
  }

  Future<String> _saveSurveyLocally(SurveyEntryModel entryInput) async {
    return await _taskStorageService.addTask(SyncTaskModel(
      id: generateUniqueId(),
      surveyName: survey.value?.name ?? 'Desconocido',
      payload: entryInput,
      repositoryKey: 'surveyRepository',
    ));
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

  Map getDepartmentAndCityFromCoords(double lat, double lon) {
    final locationData = LocationData.getLocationData();

    // Función para calcular la distancia entre dos puntos usando la fórmula de Haversine
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

    // Variables para almacenar el resultado
    String closestDepartmentName = 'Desconocido';
    String closestCityName = 'Desconocido';
    double minCityDistance = double.infinity;

    // Buscar directamente la ciudad más cercana entre todas las ciudades
    for (var country in locationData['countries']) {
      for (var department in country['departments']) {
        for (var city in department['ciudades']) {
          final cityLat = city['latitude'];
          final cityLon = city['longitude'];

          // Calcular la distancia entre las coordenadas del usuario y la ciudad
          final cityDistance = calculateDistance(lat, lon, cityLat, cityLon);

          // Si esta ciudad está más cerca que la anterior más cercana
          if (cityDistance < minCityDistance) {
            minCityDistance = cityDistance;
            closestCityName = city['name'];
            closestDepartmentName = department['departamento'];
          }
        }
      }
    }

    // Si la distancia es mayor a cierto umbral (por ejemplo, 50 km)
    // podríamos considerar que está fuera de las áreas registradas
    if (minCityDistance > 50) {
      print(
          'Advertencia: La ubicación más cercana está a $minCityDistance km de distancia');
    }

    return {
      'department': closestDepartmentName,
      'city': closestCityName,
      'distance': minCityDistance, // Opcional: para información de depuración
    };
  }
}
