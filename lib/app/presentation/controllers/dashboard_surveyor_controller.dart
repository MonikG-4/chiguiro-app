import 'package:get/get.dart';

import '../../../core/services/audio_service.dart';
import '../../../core/services/cache_storage_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/sections.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';
import '../../domain/repositories/i_dashboard_surveyor_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/local_storage_service.dart';

class DashboardSurveyorController extends GetxController {
  final IDashboardSurveyorRepository repository;
  final SyncService _syncService = Get.find<SyncService>();

  late final LocationService _locationService;
  late final AudioService _audioService;
  late final CacheStorageService _storageService;
  late final LocalStorageService _localStorage;

  final activeSurvey = Rx<Survey?>(null);
  final historicalSurveys = <Survey>[].obs;
  final surveyor = Rx<Surveyor?>(null);
  final sections = <Sections>[].obs;

  final isLoading = false.obs;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  DashboardSurveyorController(this.repository);

  @override
  Future<void> onInit() async {
    super.onInit();
    _locationService = Get.find<LocationService>();
    _audioService = Get.find<AudioService>();
    _storageService = Get.find<CacheStorageService>();
    _localStorage = Get.find<LocalStorageService>();

    MessageHandler.setupSnackbarListener(message);

    _syncService.addPostSyncCallback(() async {
      await _syncService.waitForSyncCompletion();
      await fetchSurveys();
    });

    await fetchSurveys();
  }

  Future<void> fetchSurveys() async {
    isLoading.value = true;

    try {
      final futures = await Future.wait([
        repository.fetchActiveSurveys(_storageService.authResponse!.projectId),
        repository.getHistoricalSurveys(),
        repository.getSurveyorProfile(_storageService.authResponse!.id),
        repository.fetchSurveyQuestions(_storageService.authResponse!.projectId)
      ]);

      activeSurvey.value = futures[0] as Survey;
      historicalSurveys.value = futures[1] as List<Survey>;
      surveyor.value = futures[2] as Surveyor;
      sections.value = futures[3] as List<Sections>;


      _cacheData();

      await _handlePermissions();
    } catch (e) {
      message.update((val) {
        val?.message = e.toString().replaceAll("Exception:", "");
        val?.state = 'error';
      });

      _loadCachedData();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handlePermissions() async {
    if (activeSurvey.value?.geoLocation == true) {
      await _locationService.requestLocationPermission();
    }

    if (activeSurvey.value?.voiceRecorder == true) {
      await _audioService.requestAudioPermission();
    }
  }

  void _cacheData() {
    _localStorage.saveSurvey(activeSurvey.value!);
    _localStorage.saveSurveyor(surveyor.value!);
    _localStorage.saveSections(sections);
  }

  void _loadCachedData() {
    activeSurvey.value = _localStorage.getSurvey();
    surveyor.value = _localStorage.getSurveyor();
  }
}
