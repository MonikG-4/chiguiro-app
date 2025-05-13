import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/cache_storage_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/detail_survey.dart';
import '../../domain/entities/survey.dart';
import '../../domain/entities/survey_statistics.dart';
import '../../domain/repositories/i_detail_survey_repository.dart';

class DetailSurveyController extends GetxController {
  final IDetailSurveyRepository repository;
  final ConnectivityService _connectivityService = Get.find();
  late final CacheStorageService _storageService;

  late ScrollController scrollController;

  final detailSurvey = <DetailSurvey>[].obs;

  final isLoadingStatisticSurvey = false.obs;
  final isLoadingAnswerSurvey = false.obs;
  final currentPage = 0.obs;
  final isLastPage = false.obs;
  final pageSize = 0.obs;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());
  final Rx<Survey?> survey = Rx<Survey?>(null);
  final Rx<SurveyStatistics?> surveyStatistics = Rx<SurveyStatistics?>(null);

  DetailSurveyController(this.repository);

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<CacheStorageService>();

    final args = Get.arguments;
    if (args != null) {
      survey.value = args['survey'] as Survey?;
    }

    MessageHandler.setupSnackbarListener(message);

    scrollController = ScrollController()..addListener(_scrollListener);
    _connectivityService.addCallback(true, 2, () => fetchData(clearData: true));
  }

  void fetchData({bool clearData = false}) {
    if (clearData) {
      detailSurvey.clear();
      currentPage.value = 0;
      isLastPage.value = false;
      surveyStatistics.value = null;
    }

    fetchDetailSurvey();
    fetchStatisticsSurvey();
  }

  Future<void> fetchStatisticsSurvey() async {
    if (survey.value == null) return;

    isLoadingStatisticSurvey.value = true;

    try {
      final result = await repository.fetchStatisticsSurvey(
          _storageService.authResponse!.id, survey.value!.id);

      result.fold((failure) {
        _showMessage('Error', _mapFailureToMessage(failure).replaceAll("Exception:", ""), 'error');
      }, (data) {
        surveyStatistics.value = data;
      });
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isLoadingStatisticSurvey.value = false;
    }
  }

  Future<void> fetchDetailSurvey() async {
    if (isLoadingAnswerSurvey.value || isLastPage.value || survey.value == null) {
      return;
    }

    try {
      isLoadingAnswerSurvey.value = true;

      final result = await repository.fetchSurveyDetail(
          _storageService.authResponse!.id,
          survey.value!.id,
          currentPage.value,
          pageSize.value);

      result.fold((failure) {}, (data) {
        if (data.isEmpty) {
          isLastPage.value = true;
        } else {
          detailSurvey.addAll(data);
          currentPage.value++;
        }
      });
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isLoadingAnswerSurvey.value = false;
    }
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingAnswerSurvey.value) {
      fetchDetailSurvey();
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

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
