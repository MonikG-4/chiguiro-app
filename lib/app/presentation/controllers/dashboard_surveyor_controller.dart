import 'package:get/get.dart';

import '../../domain/entities/survey.dart';
import '../../domain/entities/surveyor.dart';
import '../../domain/repositories/i_survey_repository.dart';

class DashboardSurveyorController extends GetxController {
  final ISurveyRepository repository;

  final activeSurveys = <Survey>[].obs;
  final historicalSurveys = <Survey>[].obs;
  final surveyor = Rx<Surveyor?>(null);
  final isLoading = true.obs;

  DashboardSurveyorController(this.repository);

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    if (activeSurveys.isNotEmpty &&
        historicalSurveys.isNotEmpty && surveyor.value != null) {
      return; // Data is already loaded, no need to load again
    }

    try {
      isLoading.value = true;
      final futures = await Future.wait([
        repository.getActiveSurveys(),
        repository.getHistoricalSurveys(),
        repository.getSurveyorProfile(),
      ]);

      activeSurveys.value = futures[0] as List<Survey>;
      historicalSurveys.value = futures[1] as List<Survey>;
      surveyor.value = futures[2] as Surveyor;

    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data');
    } finally {
      isLoading.value = false;
    }
  }
}
