import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/detail_survey.dart';
import '../../domain/repositories/i_detail_survey_repository.dart';

class DetailSurveyController extends GetxController {
  final IDetailSurveyRepository repository;

  late ScrollController scrollController;

  final detailSurvey = <DetailSurvey>[].obs;

  var isLoadingAnswerSurvey = false.obs;
  var currentPage = 1.obs;
  var isLastPage = false.obs;
  final int pageSize = 10;

  late int projectId = 0;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  DetailSurveyController(this.repository);

  @override
  void onInit() {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
    scrollController = ScrollController()..addListener(_scrollListener);
  }

  Future<void> fecthDetailSurvey(int surveyId) async {
    projectId = surveyId;
    if (isLoadingAnswerSurvey.value || isLastPage.value) return;

    isLoadingAnswerSurvey.value = true;

    try {
      final newItems = await repository.getSurveyDetail(
          surveyId, currentPage.value, pageSize);

      if (newItems.isEmpty) {
        isLastPage.value = true;
      } else {
        detailSurvey.addAll(newItems);
        currentPage.value++;
      }
    } finally {
      isLoadingAnswerSurvey.value = false;
    }
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200 &&
        !isLoadingAnswerSurvey.value) {
      fecthDetailSurvey(projectId);
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}