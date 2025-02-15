import 'package:chiguiro_front_app/app/presentation/services/audio_service.dart';
import 'package:get/get.dart';

import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';

import '../../domain/repositories/i_dashboard_surveyor_repository.dart';
import '../services/location_service.dart';

class DashboardSurveyorController extends GetxController {
  final IDashboardSurveyorRepository repository;

  final activeSurvey = Rx<Survey?>(null);
  final historicalSurveys = <Survey>[].obs;
  final surveyor = Rx<Surveyor?>(null);
  final isLoading = true.obs;
  late final LocationService _locationService;
  late final AudioService _audioService;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  DashboardSurveyorController(this.repository);

  @override
  Future<void> onInit() async {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
    _locationService = Get.find<LocationService>();
    _audioService = Get.find<AudioService>();

  }

  Future<void> fetchSurveys(int projectId) async {
    isLoading.value = true;
    try {
      final futures = await Future.wait([
        repository.fetchActiveSurveys(projectId),
        repository.getHistoricalSurveys(),
        repository.getSurveyorProfile(),
      ]);

      activeSurvey.value = futures[0] as Survey;
      historicalSurveys.value = futures[1] as List<Survey>;
      surveyor.value = futures[2] as Surveyor;

      if (activeSurvey.value!.geoLocation) {
        await _locationService.requestLocationPermission();
      }

      if (activeSurvey.value!.voiceRecorder) {
        await _audioService.requestAudioPermission();
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
}
