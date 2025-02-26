import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/services/cache_storage_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/detail_survey.dart';
import '../../domain/repositories/i_detail_survey_repository.dart';

class DetailSurveyController extends GetxController {
  final IDetailSurveyRepository repository;
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  late final CacheStorageService _storageService;

  late ScrollController scrollController;

  final detailSurvey = <DetailSurvey>[].obs;

  var isLoadingAnswerSurvey = false.obs;
  var currentPage = 0.obs;
  var isLastPage = false.obs;
  final int pageSize = 10;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  DetailSurveyController(this.repository);

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<CacheStorageService>();


    MessageHandler.setupSnackbarListener(message);
    scrollController = ScrollController()..addListener(_scrollListener);
    _connectivityService.addCallback(true, fecthDetailSurvey);
    fecthDetailSurvey();
  }

  Future<void> fecthDetailSurvey() async {
    if (isLoadingAnswerSurvey.value || isLastPage.value) return;

    try {
      isLoadingAnswerSurvey.value = true;

      final newItems = await repository.fetchSurveyDetail(
          _storageService.authResponse!.id, currentPage.value, pageSize);

      if (newItems.isEmpty) {
        isLastPage.value = true;
        isLoadingAnswerSurvey.value = false;
      } else {
        detailSurvey.addAll(newItems);
        currentPage.value++;
      }

    } catch (e) {
      isLoadingAnswerSurvey.value = false;
      _showMessage(e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isLoadingAnswerSurvey.value = false;
    }
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingAnswerSurvey.value) {
      fecthDetailSurvey();
    }
  }

  void _showMessage(String msg, String state) {
    message.update((val) {
      val?.message = msg;
      val?.state = state;
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
