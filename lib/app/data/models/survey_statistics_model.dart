import 'package:hive/hive.dart';

import '../../domain/entities/survey_statistics.dart';

part 'survey_statistics_model.g.dart';

@HiveType(typeId: 6)
class SurveyStatisticsModel extends HiveObject{

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
      totalEntries: json['totalEntries'],
      totalCompleted: json['totalCompleted'],
      totalUncompleted: json['totalUncompleted'],
      completedPercentage: json['completedPercentage'],
      lastSurvey: DateTime.parse(json['lastSurvey']),
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