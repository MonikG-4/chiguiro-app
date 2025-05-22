import 'package:get/get.dart';
import '../../../core/error/failures/failure.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/cache_storage_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/survey_responded.dart';
import '../../domain/entities/surveyor.dart';
import '../../domain/repositories/i_dashboard_surveyor_repository.dart';
import '../../../core/services/location_service.dart';

class DashboardSurveyorController extends GetxController {
  final IDashboardSurveyorRepository repository;
  final ConnectivityService _connectivityService = Get.find();
  late final LocationService _locationService;
  late final AudioService _audioService;
  late final CacheStorageService _storageService;

  // Variables reactivas para la UI
  final surveys = <Survey>[].obs;
  final surveysResponded = <SurveyResponded>[].obs;
  final dataSurveyor = Rx<Surveyor?>(null);

  // Estados de carga separados para cada operación
  final isChangePasswordLoading = false.obs;
  final isSurveysLoading = false.obs;
  final isSurveysRespondedLoading = false.obs;
  final isSurveyorDataLoading = false.obs;

  // Datos del encuestador
  final idSurveyor = 0.obs;
  final nameSurveyor = ''.obs;
  final surnameSurveyor = ''.obs;
  final showContent = false.obs;
  final homeCode = ''.obs;
  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  DashboardSurveyorController(this.repository);

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _initializeUserData();

    fetchSurveys();
    fetchDataSurveyor();

    _connectivityService.addCallback(
        true,
        priority: 2,
        () async {
          refreshAllData();
        },
        id: 'dashboard_surveyor');

    MessageHandler.setupSnackbarListener(message);
  }

  void _initializeServices() {
    _locationService = Get.find<LocationService>();
    _audioService = Get.find<AudioService>();
    _storageService = Get.find<CacheStorageService>();
  }

  void _initializeUserData() {
    final auth = _storageService.authResponse;
    if (auth != null) {
      nameSurveyor.value = auth.name;
      surnameSurveyor.value = auth.surname;
      idSurveyor.value = auth.id;
    }
  }

  Future<void> changePassword(String password) async {
    isChangePasswordLoading.value = true;

    final result = await repository.changePassword(
        _storageService.authResponse!.id, password);

    result.fold((failure) {
      _showMessage('Error',
          _mapFailureToMessage(failure).replaceAll("Exception:", ""), 'error');
    }, (isSuccess) {
      if (isSuccess) {
        Get.back();
        _showMessage('Cambio de contraseña',
            'Su contraseña fue actualizada correctamente', 'success');
      }
    });

    isChangePasswordLoading.value = false;
  }

  void refreshAllData() {
    fetchSurveys();
    fetchDataSurveyor();
    fetchSurveysResponded(homeCode.value);
  }

  Future<void> fetchSurveysResponded(String homeCode) async {
    if (isSurveysRespondedLoading.value) return;

    isSurveysRespondedLoading.value = true;

    try {
      final userId = _storageService.authResponse!.id;
      final surveysResult =
          await repository.fetchSurveyResponded(homeCode, userId);

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
      isSurveysRespondedLoading.value = false;
    }
  }

  Future<void> fetchSurveys() async {
    if (isSurveysLoading.value) return;

    isSurveysLoading.value = true;

    try {
      final userId = _storageService.authResponse!.id;
      final surveysResult = await repository.fetchSurveys(userId);

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

  Future<void> fetchDataSurveyor() async {
    if (isSurveyorDataLoading.value) return;

    isSurveyorDataLoading.value = true;

    try {
      final userId = _storageService.authResponse!.id;
      final result = await repository.fetchDataSurveyor(userId);

      result.fold(
        (failure) {
          _showMessage(
              'Error',
              _mapFailureToMessage(failure).replaceAll("Exception:", ""),
              'error');
        },
        (data) {
          dataSurveyor.value = data;
        },
      );
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isSurveyorDataLoading.value = false;
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
