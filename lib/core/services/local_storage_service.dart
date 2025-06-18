import 'package:hive/hive.dart';

import '../../app/data/models/survey_model.dart';
import '../../app/data/models/survey_responded_model.dart';
import '../../app/data/models/survey_statistics_model.dart';
import '../../app/data/models/surveyor_model.dart';
import '../../app/domain/entities/survey.dart';
import '../../app/domain/entities/survey_responded.dart';
import '../../app/domain/entities/statistics.dart';
import '../../app/domain/entities/surveyor.dart';

class LocalStorageService {
  final _surveysBox = Hive.box<SurveyModel>('surveysBox');
  final _surveysRespondedBox =
      Hive.box<SurveyRespondedModel>('surveysRespondedBox');
  final _statisticsBox = Hive.box<StatisticsModel>('statisticsBox');
  final _surveyorBox = Hive.box<SurveyorModel>('surveyorBox');
  final _survey6CompletedBox = Hive.box<bool>('survey6CompletedBox');

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

  bool projectsEmpty() {
    return _surveysBox.isEmpty;
  }

  void clearSurveys() {
    _surveysBox.clear();
  }

  void saveSurveysResponded(List<SurveyResponded> surveys) {
    final projectsModels =
        surveys.map((s) => SurveyRespondedModel.fromEntity(s)).toList();
    for (final project in projectsModels) {
      final existingProject = _surveysRespondedBox.get(project.survey?.id);
      if (existingProject == null || existingProject != project) {
        _surveysRespondedBox.put(project.survey?.id, project);
      }
    }
  }

  List<SurveyResponded> getSurveysResponded() {
    return _surveysRespondedBox.values.map((s) => s.toEntity()).toList();
  }

  void clearSurveysResponded() {
    _surveysRespondedBox.clear();
  }

  void saveStatisticsSurvey(int surveyorId, Statistic statistic) {
    final existingStats = _statisticsBox.get(surveyorId);
    final newStats = StatisticsModel.fromEntity(statistic);
    if (existingStats == null || existingStats != newStats) {
      _statisticsBox.put(surveyorId, newStats);
    }
  }

  Statistic getStatisticsSurvey(int surveyorId) {
    return _statisticsBox.get(surveyorId)?.toEntity() ??
        StatisticsModel.empty().toEntity();
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

  Future<void> clearAll() async {
    clearSurveyor();
    clearStatistics();
    clearSurveys();
    clearSurveysResponded();
    clearSurvey6Completed();
  }

  void setSurvey6Completed(String homeId, bool isCompleted) {
    _survey6CompletedBox.put(homeId, isCompleted);
  }


  bool isSurvey6Completed(String homeId) {
    return _survey6CompletedBox.get(homeId, defaultValue: false) ?? false;
  }

  void clearSurvey6Completed() {
    _survey6CompletedBox.clear();
  }
}
