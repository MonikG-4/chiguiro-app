import 'dart:async';

import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/cache_storage_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/repositories/i_survey_repository.dart';

class PendingSurveyController extends GetxController {
  final ISurveyRepository repository;
  CacheStorageService? _storageService;
  SyncService? _syncService;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  final idSurveyor = 0.obs;
  final surveyPending = <Map<String, dynamic>>[].obs;
  final isLoadingQuestion = false.obs;

  PendingSurveyController(this.repository);

  @override
  void onInit() {
    super.onInit();

    _storageService ??= Get.find<CacheStorageService>();
    _syncService ??= Get.find<SyncService>();

    if (idSurveyor.value == 0) {
      final auth = _storageService?.authResponse;
      if (auth != null) {
        idSurveyor.value = auth.id;
      }
    }

    print("idSurveyor: ${idSurveyor.value}");
    fetchSurveys(idSurveyor.value);

    MessageHandler.setupSnackbarListener(message);
  }

  Future<void> fetchSurveys(int surveyorId) async {
    isLoadingQuestion.value = true;

    try {
      final result = await repository.fetchSurveys(surveyorId);

      result.fold((failure) {
        _showMessage('Error', _mapFailureToMessage(failure), 'error');
      }, (data) {
        surveyPending.value = data;
      });
    } catch (e) {
      _showMessage('Error', e.toString().replaceAll("Exception:", ""), 'error');
    } finally {
      isLoadingQuestion.value = false;
    }
  }

  Future<void> saveAllPendingSurveys() async {
    _syncService?.syncPendingTasks();
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
