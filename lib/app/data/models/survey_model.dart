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
  final DateTime? closeDate;

  @HiveField(4)
  final int entriesCount;

  @HiveField(5)
  final String? logoUrl;

  @HiveField(6)
  final bool geoLocation;

  @HiveField(7)
  final bool voiceRecorder;

  SurveyModel({
    required this.id,
    required this.name,
    required this.active,
    this.closeDate,
    required this.entriesCount,
    this.logoUrl,
    required this.geoLocation,
    required this.voiceRecorder,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'],
      active: json['active'],
      closeDate: json['closeDate'] != null ? DateTime.parse(json['closeDate']) : null,
      entriesCount: json['entriesCount'],
      logoUrl: json['logoUrl'],
      geoLocation: json['geoLocation'],
      voiceRecorder: json['voiceRecorder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'active': active,
      'closeDate': closeDate?.toIso8601String(),
      'entriesCount': entriesCount,
      'logoUrl': logoUrl,
      'geoLocation': geoLocation,
      'voiceRecorder': voiceRecorder,
    };
  }

  factory SurveyModel.fromEntity(Survey survey) {
    return SurveyModel(
      id: survey.id,
      name: survey.name,
      active: survey.active,
      closeDate: survey.closeDate,
      entriesCount: survey.entriesCount,
      logoUrl: survey.logoUrl,
      geoLocation: survey.geoLocation,
      voiceRecorder: survey.voiceRecorder,
    );
  }

  Survey toEntity() {
    return Survey(
      id: id,
      name: name,
      active: active,
      closeDate: closeDate,
      entriesCount: entriesCount,
      logoUrl: logoUrl,
      geoLocation: geoLocation,
      voiceRecorder: voiceRecorder,
    );
  }
}
