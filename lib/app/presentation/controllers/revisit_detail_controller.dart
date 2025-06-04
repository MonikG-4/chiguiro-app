import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/error/failures/failure.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/cache_storage_service.dart';
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
  late final CacheStorageService _storageService;
  late LocationService _locationService;
  late final AudioService _audioService;
  late final RevisitStorageService _revisitStorageService;

  // Variables reactivas para la UI
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

    _storageService = Get.find<CacheStorageService>();
    _audioService = Get.find<AudioService>();
    _locationService = Get.find<LocationService>();
    _revisitStorageService = Get.find<RevisitStorageService>();

    revisit.value = Get.arguments;
    homeCode.value = revisit.value!.homeCode;

    print(revisit.value?.revisitNumber);

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
      // Retorna solo el punto de la revisita si no se obtiene ubicación actual
      return [LatLng(revisit.latitude, revisit.longitude)];
    }

    final current = LatLng(location.latitude, location.longitude);
    final revisitPoint = LatLng(revisit.latitude, revisit.longitude);

    return [current, revisitPoint];
  }


  Future<void> fetchSurveysResponded(String homeCode) async {
    if (isSurveysLoading.value) return;

    isSurveysLoading.value = true;

    try {
      final surveysResult =
      await repository.fetchSurveyResponded(homeCode, _storageService.authResponse!.id);

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

      final surveysResult = await repository.fetchSurveys(_storageService.authResponse!.id);

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

  Future<void> saveRevisit() async {
    try {
      isSurveysLoading.value = true;

      final revisitNumber = await _revisitStorageService.incrementRevisitCount(revisit.value!.homeCode);

      if(revisitNumber! < 3) {
        _showMessage('Revisita guardada', 'Hogar revisitado $revisitNumber veces', 'info');
      } else {
        _showMessage('Hogar finalizado', 'Hogar revisitado $revisitNumber veces', 'error');
      }

      isSurveysLoading.value = false;
    } catch (e) {
      _showMessage('Error', 'No se pudo guardar la revisita: $e', 'error');
    }
  }

  Future<void> deleteRevisit() async {
    try {
      await _revisitStorageService.removeRevisit(revisit.value!.homeCode);
      _showMessage('Hogar finalizado', 'Hogar finalizado correctamente', 'success');
     } catch (e) {
      _showMessage('Error', 'No se pudo finalizado el hogar: $e', 'error');
    }
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
