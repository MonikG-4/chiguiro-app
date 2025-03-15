import 'package:hive/hive.dart';

import '../../app/data/models/survey_model.dart';
import '../../app/data/models/survey_statistics_model.dart';
import '../../app/data/models/surveyor_model.dart';
import '../../app/domain/entities/survey.dart';
import '../../app/domain/entities/survey_statistics.dart';
import '../../app/domain/entities/surveyor.dart';

class LocalStorageService {
  final _surveysBox = Hive.box<SurveyModel>('surveysBox');
  final _statisticsBox = Hive.box<SurveyStatisticsModel>('statisticsBox');
  final _surveyorBox = Hive.box<SurveyorModel>('surveyorBox');

  void saveSurveys(List<Survey> surveys) {
    final projectsModels =
    surveys.map((s) => SurveyModel.fromEntity(s)).toList();
    for (final project in projectsModels) {
      final existingProject = _surveysBox.get(project.id);
      if (existingProject == null || existingProject != project) {
        _surveysBox.put(project.id, project);
      }
    }
  }

  List<Survey> getSurveys() {
    return _surveysBox.values.map((s) => s.toEntity()).toList();
  }

  void clearSurveys() {
    _surveysBox.clear();
  }

  void saveStatisticsSurvey(int surveyId, SurveyStatistics surveyStatistics) {
    final existingStats = _statisticsBox.get(surveyId);
    final newStats = SurveyStatisticsModel.fromEntity(surveyStatistics);
    if (existingStats == null || existingStats != newStats) {
      _statisticsBox.put(surveyId, newStats);
    }
  }

  SurveyStatistics getStatisticsSurvey(int surveyId) {
    return _statisticsBox.get(surveyId)?.toEntity() ??
        SurveyStatisticsModel.empty().toEntity();
  }

  void clearStatistics() {
    _statisticsBox.clear();
  }

  void saveSurveyor(Surveyor surveyor) {
    final existingSurveyor = _surveyorBox.get('surveyor');
    final newSurveyor = SurveyorModel.fromEntity(surveyor);
    if (existingSurveyor == null || existingSurveyor != newSurveyor) {
      _surveyorBox.put('surveyor', newSurveyor);
    }
  }

  Surveyor? getSurveyor() {
    return _surveyorBox.get('surveyor')?.toEntity();
  }

  void clearSurveyor() {
    _surveyorBox.delete('surveyor');
  }

  void clearAll() {
    clearSurveyor();
    clearStatistics();
    clearSurveys();
  }
}
