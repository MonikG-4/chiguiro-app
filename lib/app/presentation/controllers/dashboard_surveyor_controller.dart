import 'package:get/get.dart';

import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';

import '../../domain/repositories/i_dashboard_surveyor_repository.dart';

class DashboardSurveyorController extends GetxController {
  final IDashboardSurveyorRepository repository;

  final activeSurveys = <Survey>[].obs;
  final historicalSurveys = <Survey>[].obs;
  final surveyor = Rx<Surveyor?>(null);
  final isLoading = true.obs;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  DashboardSurveyorController(this.repository);

  @override
  void onInit() {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
  }

  Future<void> fetchSurveys(int projectId) async {
    isLoading.value = true;
    try {
      final futures = await Future.wait([
        repository.fetchActiveSurveys(projectId),
        repository.getHistoricalSurveys(),
        repository.getSurveyorProfile(),
      ]);

      activeSurveys.value = futures[0] as List<Survey>;
      historicalSurveys.value = futures[1] as List<Survey>;
      surveyor.value = futures[2] as Surveyor;
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
