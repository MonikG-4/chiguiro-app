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

  SurveyStatisticsModel({
    required this.totalEntries,
    required this.totalCompleted,
    required this.totalUncompleted,
    required this.completedPercentage,
  });

  factory SurveyStatisticsModel.fromEntity(SurveyStatistics entity) {
    return SurveyStatisticsModel(
      totalEntries: entity.totalEntries,
      totalCompleted: entity.totalCompleted,
      totalUncompleted: entity.totalUncompleted,
      completedPercentage: entity.completedPercentage,
    );
  }

  factory SurveyStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SurveyStatisticsModel(
      totalEntries: json['totalEntries'],
      totalCompleted: json['totalCompleted'],
      totalUncompleted: json['totalUncompleted'],
      completedPercentage: json['completedPercentage'],
    );
  }

  SurveyStatistics toEntity() {
    return SurveyStatistics(
      totalEntries: totalEntries,
      totalCompleted: totalCompleted,
      totalUncompleted: totalUncompleted,
      completedPercentage: completedPercentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'totalCompleted': totalCompleted,
      'totalUncompleted': totalUncompleted,
      'completedPercentage': completedPercentage,
    };
  }

}