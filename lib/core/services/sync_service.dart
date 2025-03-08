import 'dart:async';
import 'package:chiguiro_front_app/core/services/cache_storage_service.dart';
import 'package:get/get.dart';
import '../../app/data/models/sync_task_model.dart';
import '../../app/domain/repositories/i_survey_repository.dart';
import '../utils/message_handler.dart';
import '../utils/snackbar_message_model.dart';
import 'sync_task_storage_service.dart';

class SyncService extends GetxService {
  final SyncTaskStorageService _taskStorageService = Get.find();
  final CacheStorageService _authResponse = Get.find();
  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  final RxBool isSyncing = false.obs;
  final RxInt pendingTaskCount = 0.obs;
  final RxList<String> processingTasks = <String>[].obs;

  final _syncStatusController = StreamController<String>.broadcast();
  Stream<String> get syncStatus => _syncStatusController.stream;

  @override
  void onInit() {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
    _updatePendingTaskCount();
  }

  @override
  void onClose() {
    _syncStatusController.close();
    super.onClose();
  }

  void _updatePendingTaskCount() {
    if (_authResponse.authResponse != null) {
      pendingTaskCount.value = _taskStorageService
          .getPendingTasks(_authResponse.authResponse!.id)
          .length;
    }
  }

  Future<void> syncPendingTasks() async {
    if (isSyncing.value || _authResponse.token == null || _authResponse.token!.isEmpty) {
      return;
    }

    try {
      isSyncing.value = true;
      _syncStatusController.add('Iniciando sincronización...');

      final userId = _authResponse.authResponse!.id;
      final pendingTasks = _taskStorageService.getPendingTasks(userId);

      int tasksProcessed = 0;
      List<String> failedTaskIds = [];

      if (pendingTasks.isEmpty) {
        _syncStatusController.add('No hay encuestas pendientes');
        return;
      }

      final results = await Future.wait(
          pendingTasks.map((task) async {
            final success = await _processTask(task);
            _syncStatusController.add('Procesando: ${task.id} - ${success ? 'Éxito' : 'Fallido'}');
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

      _updatePendingTaskCount();

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
      _syncStatusController.add('Sincronización finalizada');
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
      print('Error procesando tarea ${task.id}: $e');
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
      print('Error al enviar encuesta a través de GraphQL: $e');
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
