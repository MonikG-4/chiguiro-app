import 'package:chiguiro_front_app/app/data/models/survey_statistics_model.dart';
import 'package:hive/hive.dart';

import '../../app/data/models/survey_model.dart';
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
      _surveysBox.put(project.id, project);
    }
  }

  List<Survey> getSurveys() {
    return _surveysBox.values.map((s) => s.toEntity()).toList();
  }

  void saveStatisticsSurvey(int surveyId, SurveyStatistics surveyStatistics) {
    _statisticsBox.put(
        surveyId, SurveyStatisticsModel.fromEntity(surveyStatistics));
  }

  SurveyStatistics getStatisticsSurvey(int surveyId) {
    return _statisticsBox.get(surveyId)?.toEntity() ??
        SurveyStatisticsModel.empty().toEntity();
  }

  void saveSurveyor(Surveyor surveyor) {
    _surveyorBox.put('surveyor', SurveyorModel.fromEntity(surveyor));
  }

  Surveyor? getSurveyor() {
    return _surveyorBox.get('surveyor')?.toEntity();
  }

  void clearAll() {
    _surveysBox.clear();
    _surveyorBox.clear();
  }
}
