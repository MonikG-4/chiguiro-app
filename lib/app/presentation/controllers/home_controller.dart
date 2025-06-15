import 'dart:math';

import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/revisit_storage_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../data/models/revisit_model.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/survey_responded.dart';
import '../../domain/repositories/i_home_repository.dart';

class HomeController extends GetxController {
  final IHomeRepository repository;
  final ConnectivityService connectivityService = Get.find();
  late LocationService _locationService;
  late final AudioService _audioService;
  late final AuthStorageService _storageService;
  late final RevisitStorageService _revisitStorageService;

  // Variables reactivas para la UI
  final surveys = <Survey>[].obs;
  final surveysResponded = <SurveyResponded>[].obs;

  // Estados de carga separados para cada operación
  final isChangePasswordLoading = false.obs;
  final isSurveysLoading = false.obs;
  final isSurveysRespondedLoading = false.obs;
  final isSurveyorDataLoading = false.obs;
  final isDownloadingSurveys = false.obs;
  final showContent = false.obs;
  final isCodeGenerated = false.obs;
  final isSavingRevisit = false.obs;

  // Datos del encuestador
  final idSurveyor = 0.obs;
  final nameSurveyor = ''.obs;
  final surnameSurveyor = ''.obs;
  final homeCode = ''.obs;

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
    // Rename to Auth Service
    _storageService = Get.find<AuthStorageService>();
    _revisitStorageService = Get.find<RevisitStorageService>();
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
      // Configurar listeners
      connectivityService.addCallback(true, priority: 2, () async {
        refreshAllData();
      }, id: 'dashboard_surveyor');

      MessageHandler.setupSnackbarListener(message);

      // Carga inicial con splash
      refreshAllData();
    } catch (e) {
      print('Error initializing dashboard: $e');
    }
  }

  void generateHomeCode() {
    final now = DateTime.now();

    final letters = String.fromCharCodes([
      65 + (now.millisecond % 26), // Letra 1
      65 + (now.second % 26), // Letra 2
      65 + (now.minute % 26), // Letra 3
      65 + (now.hour % 26), // Letra 4
    ]);

    final random = Random(
        now.microsecond + now.millisecond + now.second + now.minute + now.hour);
    final numbers = List.generate(4, (_) => random.nextInt(10)).join();

    homeCode.value = "$letters-$numbers";
    isCodeGenerated.value = true;
  }

  void resetHomeCode() {
    homeCode.value = "";
    isCodeGenerated.value = false;
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

  Future<void> refreshAllData(
      {bool all = true, bool forceServer = false}) async {
    if (all) {
      await fetchSurveys(forceServer: forceServer);
    }
    await fetchSurveysResponded(homeCode.value);
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

  Future<void> saveRevisit(String reason) async {
    try {
      showContent.value = false;
      isSurveysLoading.value = true;
      await _locationService.initializeCachedPosition();
      final location = _locationService.cachedPosition;

      if (location == null) {
        _showMessage('Error', 'No se pudo obtener la ubicación', 'error');
        return;
      }

      final address = await _locationService.getAddressFromLatLng(
        location.latitude,
        location.longitude,
      );

      final revisit = RevisitModel(
        homeCode: homeCode.value,
        latitude: location.latitude,
        longitude: location.longitude,
        totalSurveys: surveysResponded.length,
        address: address,
        revisitNumber: 1,
        date: DateTime.now(),
        reason: reason,
      );

      await _revisitStorageService.addRevisit(revisit);

      _showMessage('Revisita guardada', 'Motivo: $reason', 'success');

      resetHomeCode();
      isSurveysLoading.value = false;
    } catch (e) {
      _showMessage('Error', 'No se pudo guardar la revisita: $e', 'error');
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
