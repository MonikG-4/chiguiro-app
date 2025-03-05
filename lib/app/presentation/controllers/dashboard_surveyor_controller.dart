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
  final historicalSurveys = <Survey>[].obs;
  final surveyor = Rx<Surveyor?>(null);
  final sections = <Sections>[].obs;

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

      final isSuccess = await repository.changePassword(_storageService.authResponse!.id, password);

      if (isSuccess) {
        Get.back();
        message.update((val) {
          val?.message =
          'Contraseña actualizada correctamente.';
          val?.state = 'success';
        });
      }
    } catch (e) {
      message.update((val) {
        val?.message = e.toString().replaceAll("Exception:", "");
        val?.state = 'error';
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSurveys() async {
    isLoading.value = true;

    try {
      surveys.value =
          await repository.fetchSurveys(_storageService.authResponse!.id);

      await _handlePermissions(surveys);
    } catch (e) {
      print('Error durante fetchSurveys: $e');
      message.update((val) {
        val?.message = e.toString().replaceAll("Exception:", "");
        val?.state = 'error';
      });
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



    activeSurvey.refresh();
    update();
  }
}
