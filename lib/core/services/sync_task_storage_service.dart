import 'package:hive/hive.dart';
import '../../app/data/models/sync_task_model.dart';

class SyncTaskStorageService {
  final Box<SyncTaskModel> _taskBox = Hive.box<SyncTaskModel>('sync_tasks');

  Future<String> addTask(SyncTaskModel task) async {
    await _taskBox.put(task.id, task);
    return task.id;
  }

  List<SyncTaskModel> getPendingTasks(int userId) {
    return _taskBox.values
        .where((task) => !task.isProcessing && task.payload.pollsterId == userId)
        .toList();
  }

  Future<void> markTaskProcessing(String taskId, bool processing) async {
    final task = _taskBox.get(taskId);
    if (task != null) {
      task.isProcessing = processing;
      await task.save();
    }
  }

  Future<void> removeTask(String taskId) async {
    await _taskBox.delete(taskId);
  }

  Future<void> clearAllTasks() async {
    await _taskBox.clear();
  }
}
