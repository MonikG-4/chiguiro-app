import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/cache_storage_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';
import '../../domain/repositories/i_dashboard_surveyor_repository.dart';
import '../../../core/services/location_service.dart';

class DashboardSurveyorController extends GetxController {
  final IDashboardSurveyorRepository repository;
  final ConnectivityService _connectivityService = Get.find();

  late final LocationService _locationService;
  late final AudioService _audioService;
  late final CacheStorageService _storageService;

  final surveys = <Survey>[].obs;
  final dataSurveyor = Rx<Surveyor?>(null);

  final isLoading = false.obs;
  final idSurveyor = 0.obs;
  final nameSurveyor = ''.obs;
  final surnameSurveyor = ''.obs;

  final showContent = false.obs;
  final homeCode = ''.obs;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  DashboardSurveyorController(this.repository);

  @override
  Future<void> onInit() async {
    super.onInit();
    _locationService = Get.find<LocationService>();
    _audioService = Get.find<AudioService>();
    _storageService = Get.find<CacheStorageService>();

    nameSurveyor.value = _storageService.authResponse!.name;
    surnameSurveyor.value = _storageService.authResponse!.surname;
    idSurveyor.value = _storageService.authResponse!.id;

    await fetchSurveys();

    _connectivityService.addCallback(true, fetchSurveys);

    MessageHandler.setupSnackbarListener(message);
  }

  Future<void> changePassword(String password) async {
    isLoading.value = true;

    final result = await repository.changePassword(
        _storageService.authResponse!.id, password);

    result.fold(
            (failure) {
          _showMessage('Error', _mapFailureToMessage(failure), 'error');
        },
            (isSuccess) {
          if (isSuccess) {
            Get.back();
            _showMessage('Cambio de contraseña',
                'Su contraseña fue actualizada correctamente', 'success');
          }
        }
    );

    isLoading.value = false;
  }

  Future<void> fetchSurveys() async {
    surveys.clear();
    isLoading.value = true;

    try {
      final surveysResult = await repository.fetchSurveys(_storageService.authResponse!.id);
      final dataSurveyorResult = await repository.fetchDataSurveyor(_storageService.authResponse!.id);

      final surveysList = surveysResult.fold(
            (failure) {
          _showMessage('Error', _mapFailureToMessage(failure), 'error');
          return <Survey>[];
        },
            (data) => data,
      );

      dataSurveyorResult.fold(
            (failure) {
          _showMessage('Error', _mapFailureToMessage(failure), 'error');
        },
            (data) {
          dataSurveyor.value = data;
        },
      );

      if (surveysList.isNotEmpty) {
        surveys.value = surveysList..sort((a, b) => a.id.compareTo(b.id));
        await _handlePermissions(surveys);
      }
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isLoading.value = false;
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
        continue;
      }
      if (survey.voiceRecorder == true && !audioPermissionRequested) {
        await _audioService.requestAudioPermission();
        audioPermissionRequested = true;
        await Future.delayed(const Duration(seconds: 1));
      }
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