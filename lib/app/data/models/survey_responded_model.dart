import 'package:hive/hive.dart';
import '../../domain/entities/survey.dart';

part 'survey_responded_model.g.dart';

@HiveType(typeId: 8)
class SurveyRespondedModel extends HiveObject {
  @HiveField(0)
  final int totalEntries;

  @HiveField(1)
  final DateTime lastSurvey;

  @HiveField(2)
  final int surveyId;

  @HiveField(3)
  final String surveyName;

  SurveyRespondedModel({
    required this.totalEntries,
    required this.lastSurvey,
    required this.surveyId,
    required this.surveyName,
  });

  factory SurveyRespondedModel.fromJson(Map<String, dynamic> json) {
    return SurveyRespondedModel(
      totalEntries: json['totalEntries'],
      lastSurvey: json['lastSurvey'] != null ? DateTime.parse(json['lastSurvey']) : DateTime.now(),
      surveyId: int.tryParse(json['project']['id'].toString()) ?? 0,
      surveyName: json['project']['name'],
    );
  }

  factory SurveyRespondedModel.fromEntity(Survey survey) {
    return SurveyRespondedModel(
      totalEntries: survey.entriesCount,
      lastSurvey: survey.lastSurvey!,
      surveyId: survey.id,
      surveyName: survey.name,
    );
  }

  Survey toEntity() {
    return Survey(
      id: surveyId,
      name: surveyName,
      lastSurvey: lastSurvey,
      entriesCount: totalEntries,
      geoLocation: false,
      voiceRecorder: false,
      sections: [],
    );
  }
}
