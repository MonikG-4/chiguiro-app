import 'package:hive/hive.dart';
import '../../domain/entities/survey_responded.dart';
import 'survey_model.dart';

part 'survey_responded_model.g.dart';

@HiveType(typeId: 8)
class SurveyRespondedModel extends HiveObject {
  @HiveField(0)
  final int totalEntries;

  @HiveField(1)
  final DateTime lastSurvey;

  @HiveField(2)
  final SurveyModel? survey;


  SurveyRespondedModel({
    required this.totalEntries,
    required this.lastSurvey,
    this.survey,
  });

  factory SurveyRespondedModel.fromJson(Map<String, dynamic> json) {
    return SurveyRespondedModel(
      totalEntries: json['totalEntries'] ?? 0,
      lastSurvey: json['lastSurvey'] != null
          ? DateTime.tryParse(json['lastSurvey']) ?? DateTime.now()
          : DateTime.now(),
      survey: json['project'] != null
          ? SurveyModel.fromJson(json['project'])
          : null,
    );
  }


  factory SurveyRespondedModel.fromEntity(SurveyResponded survey) {
    return SurveyRespondedModel(
      totalEntries: survey.totalEntries,
      lastSurvey: survey.lastSurvey,
      survey: SurveyModel.fromEntity(survey.survey),
    );
  }

  SurveyResponded toEntity() {
    return SurveyResponded(
      lastSurvey: lastSurvey,
      totalEntries: totalEntries,
      survey: survey!.toEntity(),
    );
  }
}
