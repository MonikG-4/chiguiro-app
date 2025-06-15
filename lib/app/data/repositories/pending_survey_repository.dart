import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/sync_task_storage_service.dart';
import '../../domain/repositories/i_pending_survey_repository.dart';
import 'base_repository.dart';

class PendingSurveyRepository extends BaseRepository implements IPendingSurveyRepository {
  final SyncTaskStorageService _syncTaskStorageService = Get.find();

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchSurveys(
      int surveyorId) async {
    try {
      final tasks = _syncTaskStorageService.getPendingTasks(surveyorId);
      final result = tasks.map((task) =>
      {
        'surveyName': task.surveyName,
        'id': task.id,
        'payload': task.payload,
      }).toList();

      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}