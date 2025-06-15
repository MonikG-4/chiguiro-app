import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../core/error/failures/failure.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/revisit_storage_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../data/models/revisit_model.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/survey_responded.dart';
import '../../domain/repositories/i_home_repository.dart';

class RevisitDetailController extends GetxController {
  final IHomeRepository repository;
  late final AuthStorageService _storageService;
  late LocationService _locationService;
  late final AudioService _audioService;
  late final RevisitStorageService _revisitStorageService;

  final revisit = Rxn<RevisitModel>();
  final surveys = <Survey>[].obs;
  final surveysResponded = <SurveyResponded>[].obs;
  final homeCode = ''.obs;

  // Estados de carga separados para cada operación
  final isSurveysLoading = false.obs;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  RevisitDetailController(this.repository);

  @override
  void onInit() {
    super.onInit();

    _storageService = Get.find<AuthStorageService>();
    _audioService = Get.find<AudioService>();
    _locationService = Get.find<LocationService>();
    _revisitStorageService = Get.find<RevisitStorageService>();

    revisit.value = Get.arguments;
    homeCode.value = revisit.value!.homeCode;

    MessageHandler.setupSnackbarListener(message);
    refreshAllData();
  }

  Future<void> refreshAllData({bool all = true}) async {
    if (all) {
      await fetchSurveys();
    }
    await fetchSurveysResponded(homeCode.value);
  }

  Future<List<LatLng>> getCurrentToRevisitRoute(RevisitModel revisit) async {
    await _locationService.initializeCachedPosition();
    final location = _locationService.cachedPosition;

    if (location == null) {
      return [LatLng(revisit.latitude, revisit.longitude)];
    }

    final start = '${location.longitude},${location.latitude}';
    final end = '${revisit.longitude},${revisit.latitude}';

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
      }
    } catch (e) {
      print('Error obteniendo ruta OSRM: $e');
    }

    // Fallback: línea recta
    return [
      LatLng(location.latitude, location.longitude),
      LatLng(revisit.latitude, revisit.longitude)
    ];
  }

  Future<void> fetchSurveysResponded(String homeCode) async {
    if (isSurveysLoading.value) return;

    isSurveysLoading.value = true;

    try {
      final surveysResult = await repository.fetchSurveyResponded(
          homeCode, _storageService.authResponse!.id);

      surveysResult.fold(
        (failure) {
          _showMessage(
              'Error',
              _mapFailureToMessage(failure).replaceAll("Exception:", ""),
              'error');
        },
        (data) {
          surveysResponded.value = data
              .where((survey) => survey.totalEntries > 0)
              .toList()
            ..sort((a, b) => a.survey.id.compareTo(b.survey.id));
        },
      );
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isSurveysLoading.value = false;
    }
  }

  Future<void> fetchSurveys() async {
    if (isSurveysLoading.value) return;

    isSurveysLoading.value = true;

    try {
      final surveysResult =
          await repository.fetchSurveys(_storageService.authResponse!.id);

      surveysResult.fold(
        (failure) {
          _showMessage(
              'Error',
              _mapFailureToMessage(failure).replaceAll("Exception:", ""),
              'error');
        },
        (data) {
          surveys.value = data..sort((a, b) => a.id.compareTo(b.id));
          _handlePermissions(data);
        },
      );
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isSurveysLoading.value = false;
    }
  }

  Future<void> saveRevisit(String newReason) async {
    try {
      isSurveysLoading.value = true;

      final updated = await _revisitStorageService
          .incrementRevisitCount(revisit.value!.homeCode, newReason: newReason);

      if (updated == null) {
        _showMessage('Hogar finalizado',
            'Hogar revisitado 3 veces, se ha finalizado automáticamente.', 'error');
      } else {
        revisit.value = updated;
        _showMessage('Revisita guardada',
            'Hogar revisitado ${updated.revisitNumber} veces', 'info');
      }

      isSurveysLoading.value = false;
    } catch (e) {
      _showMessage('Error', 'No se pudo guardar la revisita: $e', 'error');
    }
  }

  Future<void> deleteRevisit() async {
    try {
      await _revisitStorageService.removeRevisit(revisit.value!.homeCode);
      _showMessage(
          'Hogar finalizado', 'Hogar finalizado correctamente', 'success');
    } catch (e) {
      _showMessage('Error', 'No se pudo finalizado el hogar: $e', 'error');
    }
  }

  Future<RevisitModel?> getRevisit() async {
    return await _revisitStorageService.getRevisitByHomeCode(revisit.value!.homeCode);
  }

  Future<void> _handlePermissions(List<Survey> surveys) async {
    bool locationPermissionRequested = false;
    bool audioPermissionRequested = false;
    for (var survey in surveys) {
      if (survey.geoLocation == true && !locationPermissionRequested) {
        await _locationService.requestLocationPermission();
        locationPermissionRequested = true;
        await Future.delayed(const Duration(seconds: 1));
      }
      if (survey.voiceRecorder == true && !audioPermissionRequested) {
        await _audioService.requestAudioPermission();
        audioPermissionRequested = true;
        await Future.delayed(const Duration(seconds: 1));
      }
      if (locationPermissionRequested && audioPermissionRequested) break;
    }
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
}
