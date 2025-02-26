import 'package:hive/hive.dart';

import '../../app/data/models/sections_model.dart';
import '../../app/data/models/survey_model.dart';
import '../../app/data/models/surveyor_model.dart';
import '../../app/domain/entities/sections.dart';
import '../../app/domain/entities/survey.dart';
import '../../app/domain/entities/surveyor.dart';


class LocalStorageService {
  final _surveysBox = Hive.box<SurveyModel>('surveysBox');
  final _surveyorBox = Hive.box<SurveyorModel>('surveyorBox');
  final _sectionsBox = Hive.box<SectionsModel>('sectionsBox');

  void saveSurvey(Survey survey) {
    _surveysBox.put('activeSurvey', SurveyModel.fromEntity(survey));
  }

  Survey? getSurvey() {
    return _surveysBox.get('activeSurvey')?.toEntity();
  }

  void saveSurveyor(Surveyor surveyor) {
    _surveyorBox.put('surveyor', SurveyorModel.fromEntity(surveyor));
  }

  Surveyor? getSurveyor() {
    return _surveyorBox.get('surveyor')?.toEntity();
  }

  void saveSections(List<Sections> sections) {
    final sectionsModels = sections.map((s) => SectionsModel.fromEntity(s)).toList();
    for (final section in sectionsModels) {
      _sectionsBox.put(section.id, section);
    }
  }

  List<Sections> getSections() {
    return _sectionsBox.values.map((s) => s.toEntity()).toList();
  }

  void clearAll() {
    _surveysBox.clear();
    _surveyorBox.clear();
    _sectionsBox.clear();
  }
}
