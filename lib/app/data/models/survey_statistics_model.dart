import 'package:hive/hive.dart';

import '../../domain/entities/survey_statistics.dart';

part 'survey_statistics_model.g.dart';

@HiveType(typeId: 6)
class SurveyStatisticsModel extends HiveObject {
  @HiveField(0)
  final int totalEntries;
  @HiveField(1)
  final int totalCompleted;
  @HiveField(2)
  final int totalUncompleted;
  @HiveField(3)
  final String completedPercentage;
  @HiveField(4)
  final DateTime lastSurvey;

  SurveyStatisticsModel({
    required this.totalEntries,
    required this.totalCompleted,
    required this.totalUncompleted,
    required this.completedPercentage,
    required this.lastSurvey,
  });

  factory SurveyStatisticsModel.fromEntity(SurveyStatistics entity) {
    return SurveyStatisticsModel(
      totalEntries: entity.totalEntries,
      totalCompleted: entity.totalCompleted,
      totalUncompleted: entity.totalUncompleted,
      completedPercentage: entity.completedPercentage,
      lastSurvey: entity.lastSurvey,
    );
  }

  factory SurveyStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SurveyStatisticsModel(
      totalEntries: json['totalEntries'] ?? 0,
      totalCompleted: json['totalCompleted'] ?? 0,
      totalUncompleted: json['totalUncompleted'] ?? 0,
      completedPercentage: json['completedPercentage'] ?? '0',
      lastSurvey: json['lastSurvey'] != null
          ? DateTime.parse(json['lastSurvey'])
          : DateTime(1970),
    );
  }

  factory SurveyStatisticsModel.empty() {
    return SurveyStatisticsModel(
      totalEntries: 0,
      totalCompleted: 0,
      totalUncompleted: 0,
      completedPercentage: '0',
      lastSurvey: DateTime(1970),
    );
  }

  SurveyStatistics toEntity() {
    return SurveyStatistics(
      totalEntries: totalEntries,
      totalCompleted: totalCompleted,
      totalUncompleted: totalUncompleted,
      completedPercentage: completedPercentage,
      lastSurvey: lastSurvey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'totalCompleted': totalCompleted,
      'totalUncompleted': totalUncompleted,
      'completedPercentage': completedPercentage,
      'lastSurvey': lastSurvey.toIso8601String(),
    };
  }
}
