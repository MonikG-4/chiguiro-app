import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/survey_responded.dart';
import '../../domain/repositories/i_home_repository.dart';

class HomeController extends GetxController {
  final IHomeRepository repository;
  final ConnectivityService connectivityService = Get.find();
  late LocationService _locationService;
  late final AudioService _audioService;
  late final AuthStorageService _storageService;

  final surveys = <Survey>[].obs;
  final surveysResponded = <SurveyResponded>[].obs;

  final isSurveysLoading = false.obs;
  final isSurveysRespondedLoading = false.obs;
  final isSurveyorDataLoading = false.obs;
  final showContent = false.obs;
  final isCodeGenerated = false.obs;

  final idSurveyor = 0.obs;
  final nameSurveyor = ''.obs;
  final surnameSurveyor = ''.obs;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  HomeController(this.repository);

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    _initializeUserData();
  }

  @override
  void onReady() {
    super.onReady();
    _initializeDashboard();
  }

  void _initializeServices() {
    _locationService = Get.find<LocationService>();
    _audioService = Get.find<AudioService>();
    _storageService = Get.find<AuthStorageService>();
  }

  void _initializeUserData() {
    final auth = _storageService.authResponse;
    if (auth != null) {
      nameSurveyor.value = auth.name;
      surnameSurveyor.value = auth.surname;
      idSurveyor.value = auth.id;
    }
  }

  Future<void> _initializeDashboard() async {
    try {
      connectivityService.addCallback(true, priority: 2, () async {
        await refreshAllData(forceServer: true);
      }, id: 'dashboard_surveyor');

      MessageHandler.setupSnackbarListener(message);

      await refreshAllData(forceServer: true);
    } catch (e) {
      print('Error initializing dashboard: $e');
    }
  }

  Future<void> refreshAllData(
      {bool all = true, bool forceServer = false}) async {
    if (all) {
      await fetchSurveys(forceServer: forceServer);
    }
    await fetchSurveysResponded();
  }

  Future<void> fetchSurveysResponded() async {
    if (isSurveysRespondedLoading.value) return;

    isSurveysRespondedLoading.value = true;

    try {
      final userId = _storageService.authResponse!.id;
      final surveysResult =
          await repository.fetchSurveyResponded(userId);

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

  Future<void> fetchSurveys({bool forceServer = false}) async {
    if (isSurveysLoading.value) return;

    isSurveysLoading.value = true;

    try {
      final userId = _storageService.authResponse!.id;
      print(
          "FETCHING PROJECTS -----------------------------------------------------------------");
      final surveysResult =
          await repository.fetchSurveys(userId, forceServer: forceServer);

      surveysResult.fold(
        (failure) {
          _showMessage(
              'Error',
              _mapFailureToMessage(failure).replaceAll("Exception:", ""),
              'error');
        },
        (data) {
          // Natural Backend Sort....
          surveys.value = data; //..sort((a, b) => a.id.compareTo(b.id));

          _handlePermissions(data);
        },
      );
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isSurveysLoading.value = false;
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
