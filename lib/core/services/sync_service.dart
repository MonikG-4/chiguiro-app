import 'dart:async';
import 'package:get/get.dart';
import '../../app/data/models/sync_task_model.dart';
import '../../app/domain/repositories/i_survey_repository.dart';
import 'sync_task_storage_service.dart';

class SyncService extends GetxService {
  final SyncTaskStorageService _taskStorageService = Get.find();
  final RxBool isSyncing = false.obs;


  Future<void> syncPendingTasks() async {
    if (isSyncing.value) return;
    try {
      isSyncing.value = true;
      final pendingTasks = _taskStorageService.getPendingTasks();
      for (final task in pendingTasks) {
        await _processTask(task);
      }
    } catch (e) {
      print("Error en la sincronización: $e");
    } finally {
      isSyncing.value = false;
    }
  }


  Future<void> _processTask(SyncTaskModel task) async {
    await _taskStorageService.markTaskProcessing(task.id, true);
    if (await _sendTaskToServer(task)) {
      await _taskStorageService.removeTask(task.id);
    } else {
      await _taskStorageService.markTaskProcessing(task.id, false);
    }
  }

  Future<bool> _sendTaskToServer(SyncTaskModel task) async {
    try {
      final repository = _getRepository(task.repositoryKey);
      return await repository.saveSurveyResults(task.payload);
    } catch (e) {
      print('Error enviando tarea: $e');
      return false;
    }
  }

  dynamic _getRepository(String key) {
    switch (key) {
      case 'surveyRepository':
        return Get.find<ISurveyRepository>();
      default:
        throw Exception('Repositorio no reconocido: $key');
    }
  }
}
