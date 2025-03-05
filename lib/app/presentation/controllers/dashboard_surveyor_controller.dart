import 'package:get/get.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/services/cache_storage_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/sections.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';
import '../../domain/repositories/i_dashboard_surveyor_repository.dart';
import '../../../core/services/location_service.dart';

class DashboardSurveyorController extends GetxController {
  final IDashboardSurveyorRepository repository;
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  late final LocationService _locationService;
  late final AudioService _audioService;
  late final CacheStorageService _storageService;

  final surveys = <Survey>[].obs;
  final dataSurveyor = Rx<Surveyor?>(null);

  final isLoading = false.obs;
  final nameSurveyor = ''.obs;
  final surnameSurveyor = ''.obs;

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

    await fetchSurveys();

    _connectivityService.addCallback(true, fetchSurveys);

    MessageHandler.setupSnackbarListener(message);
  }


  Future<void> changePassword(String password) async {
    try {
      isLoading.value = true;

      final isSuccess = await repository.changePassword(
          _storageService.authResponse!.id, password);

      if (isSuccess) {
        Get.back();
        _showMessage('Cambio de contraseña', 'Su contraseña fue actualizada correctamente', 'success');
      }
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> fetchSurveys() async {
    isLoading.value = true;

    try {
      
      final future = await Future.wait([
        repository.fetchSurveys(_storageService.authResponse!.id),
        repository.fetchDataSurveyor(_storageService.authResponse!.id),
      ]);

      surveys.value = future[0] as List<Survey>;
      dataSurveyor.value = future[1] as Surveyor;

      await _handlePermissions(surveys);
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



  void _showMessage(String title, String msg, String state) {
    message.update((val) {
      val?.title = title;
      val?.message = msg;
      val?.state = state;
    });
  }
}
