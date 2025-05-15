import 'package:chiguiro_front_app/app/data/models/sections_model.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/survey.dart';

part 'survey_model.g.dart';

@HiveType(typeId: 2)
class SurveyModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool active;

  @HiveField(3)
  final DateTime? lastSurvey;

  @HiveField(4)
  final int entriesCount;

  @HiveField(5)
  final bool geoLocation;

  @HiveField(6)
  final bool voiceRecorder;

  @HiveField(7)
  final List<SectionsModel> sections;

  SurveyModel({
    required this.id,
    required this.name,
    required this.active,
    this.lastSurvey,
    required this.entriesCount,
    required this.geoLocation,
    required this.voiceRecorder,
    required this.sections
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      active: json['active'] ?? false,
      lastSurvey: json['lastSurvey'] != null ? DateTime.parse(json['lastSurvey']) : null,
      entriesCount: json['entriesCount'] ?? 0,
      geoLocation: json['geoLocation'] ?? false,
      voiceRecorder: json['voiceRecorder'] ?? false,
      sections: json['sections'] != null ? List<SectionsModel>.from(json['sections'].map((x) => SectionsModel.fromJson(x))) : [],

    );
  }


  factory SurveyModel.fromEntity(Survey survey) {
    return SurveyModel(
      id: survey.id,
      name: survey.name,
      active: survey.active,
      lastSurvey: survey.lastSurvey,
      entriesCount: survey.entriesCount,
      geoLocation: survey.geoLocation,
      voiceRecorder: survey.voiceRecorder,
      sections: survey.sections.map((s) => SectionsModel.fromEntity(s)).toList(),
    );
  }

  Survey toEntity() {
    return Survey(
      id: id,
      name: name,
      active: active,
      lastSurvey: lastSurvey,
      entriesCount: entriesCount,
      geoLocation: geoLocation,
      voiceRecorder: voiceRecorder,
      sections: sections.map((s) => s.toEntity()).toList(),
    );
  }
}
