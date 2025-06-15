import 'dart:async';
import 'package:get/get.dart';
import '../../app/data/models/sync_task_model.dart';
import '../../app/domain/repositories/i_survey_repository.dart';
import '../utils/message_handler.dart';
import '../utils/snackbar_message_model.dart';
import 'auth_storage_service.dart';
import 'connectivity_service.dart';
import 'sync_task_storage_service.dart';

class SyncService extends GetxService {
  final SyncTaskStorageService _taskStorageService = Get.find<SyncTaskStorageService>();
  final AuthStorageService _authResponse = Get.find();
  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());
  final ConnectivityService _connectivityService = Get.find();

  final RxBool isSyncing = false.obs;
  final RxList<String> processingTasks = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
    syncPendingTasks();

    _connectivityService.addCallback(
        true,
        priority: 1,
        () async { await syncPendingTasks(); },
        id: 'sync_service'
    );
  }

  Future<void> syncPendingTasks() async {
    if (isSyncing.value || _authResponse.token == null || _authResponse.token!.isEmpty) {
      return;
    }

    try {
      isSyncing.value = true;

      final userId = _authResponse.authResponse!.id;
      final pendingTasks = _taskStorageService.getPendingTasks(userId);

      int tasksProcessed = 0;
      List<String> failedTaskIds = [];

      if (pendingTasks.isEmpty) {
        if (Get.overlayContext != null) {
          _showMessage('Encuestas', 'No hay encuestas pendientes para enviar', 'success');
        }
        return;
      }


      final results = await Future.wait(
          pendingTasks.map((task) async {
            final success = await _processTask(task);
            return MapEntry(task.id, success);
          })
      );

      for (var result in results) {
        if (result.value) {
          tasksProcessed++;
        } else {
          failedTaskIds.add(result.key);
        }
      }

      if (tasksProcessed > 0 && failedTaskIds.isEmpty) {
        _showMessage(
            'Encuestas',
            'Se enviaron $tasksProcessed encuestas correctamente',
            'success'
        );
      } else if (tasksProcessed > 0 && failedTaskIds.isNotEmpty) {
        _showMessage(
            'Sincronización Parcial',
            'Se enviaron $tasksProcessed encuestas, pero ${failedTaskIds.length} fallaron',
            'warning'
        );
      } else if (tasksProcessed == 0 && pendingTasks.isNotEmpty) {
        _showMessage(
            'Error',
            'No se pudo enviar ninguna encuesta pendiente',
            'error'
        );
      }
    } catch (e) {
      _showMessage(
          'Error',
          'Ocurrió un error durante la sincronización: ${e.toString()}',
          'error'
      );
    } finally {
      isSyncing.value = false;
    }
  }

  Future<bool> _processTask(SyncTaskModel task) async {
    try {
      processingTasks.add(task.id);
      await _taskStorageService.markTaskProcessing(task.id, true);

      final result = await _handleRepositoryRequest(task);

      if (result) {
        await _taskStorageService.removeTask(task.id);
        processingTasks.remove(task.id);
        return true;
      } else {
        await _taskStorageService.markTaskProcessing(task.id, false);
        processingTasks.remove(task.id);
        return false;
      }
    } catch (e) {
      await _taskStorageService.markTaskProcessing(task.id, false);
      processingTasks.remove(task.id);
      return false;
    }
  }

  Future<bool> _handleRepositoryRequest(SyncTaskModel task) async {
    try {
      switch (task.repositoryKey) {
        case 'surveyRepository':
          final ISurveyRepository surveyRepository = Get.find();
          final result = await surveyRepository.saveSurveyResults(task.payload.toJson());
          return result.fold(
                  (failure) => false,
                  (success) => success
          );
        default:
          throw Exception('Repositorio no reconocido: ${task.repositoryKey}');
      }
    } catch (e) {
      return false;
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
