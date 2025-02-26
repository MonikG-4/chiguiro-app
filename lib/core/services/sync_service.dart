import 'dart:async';
import 'package:get/get.dart';

import '../../app/data/models/sync_task_model.dart';
import '../../app/domain/repositories/i_survey_repository.dart';
import 'connectivity_service.dart';
import 'sync_task_storage_service.dart';

class SyncService extends GetxService {
  final SyncTaskStorageService _taskStorageService = Get.find();
  final ConnectivityService _connectivityService = Get.find();

  final RxBool isSyncing = false.obs;
  bool _isSyncing = false;
  Completer<bool> _syncCompleter = Completer<bool>();
  final List<Function> _callbacks = [];

  SyncService();

  @override
  void onInit() {
    super.onInit();
    _connectivityService.addCallback(true, () {
      if (!isSyncing.value) {
        syncPendingTasks();
      }
    });  }

  void addPostSyncCallback(Function callback) {
    _callbacks.add(callback);

    print('pendientes; ${_taskStorageService.getPendingTasks().length}');
    print('Callback agregado');
  }

  void _executeCallbacks() {
    for (final callback in _callbacks) {
      callback();
      print('Callback ejecutado');
    }
    _callbacks.clear();
  }

  Future<void> syncPendingTasks() async {
    if (_isSyncing) return;
    _isSyncing = true;
    isSyncing.value = true;

    if (_syncCompleter.isCompleted) {
      _syncCompleter = Completer<bool>();
    }

    try {
      final pendingTasks = _taskStorageService.getPendingTasks();
      for (final task in pendingTasks) {
        await _processTask(task);
        print('Tarea procesada: ${task.id}');
      }
    } catch (e) {
      print("Error en la sincronización: $e");
    } finally {
      _isSyncing = false;
      isSyncing.value = false;

      if (!_syncCompleter.isCompleted) {
        _syncCompleter.complete(true);
      }

      _executeCallbacks();
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
      switch (task.endpoint) {
        case 'saveSurvey':
          return await repository.saveSurveyResults(task.payload);
        default:
          print('Endpoint no reconocido: \${task.endpoint}');
          return false;
      }
    } catch (e) {
      print('Fallo al enviar tarea \${task.id}: $e');
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

  Future<void> waitForSyncCompletion() async {
    if (_isSyncing) {
      await _syncCompleter.future;
    }
  }

}
