import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/sync_task_storage_service.dart';
import '../../domain/repositories/i_survey_repository.dart';
import '../providers/survey_provider.dart';
import 'base_repository.dart';

class SurveyRepository extends BaseRepository implements ISurveyRepository {
  final SurveyProvider provider;
  final SyncTaskStorageService _syncTaskStorageService = Get.find();

  SurveyRepository(this.provider);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchSurveys(int surveyorId) async {
    try {
      final tasks = _syncTaskStorageService.getPendingTasks(surveyorId);
      final result = tasks.map((task) => {
        'endpoint': task.endpoint,
        'id': task.id,
        'payload': task.payload,
      }).toList();

      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveSurveyResults(Map<String, dynamic> entryInput) async {
    return safeApiCall<bool>(
      request: () => provider.saveSurveyResults(entryInput),
      onSuccess: (data) => data['entry'].isNotEmpty,
      dataKey: 'entry',
      unknownErrorMessage: 'No se logró enviar la encuesta, intente nuevamente',
    ).then((either) => either.fold(
            (failure) => const Right<Failure, bool>(false),
            (success) => Right<Failure, bool>(success)
    ));
  }
}