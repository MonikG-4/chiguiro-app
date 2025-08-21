import 'package:hive/hive.dart';

import '../../domain/entities/statistics.dart';
import 'statistic_day_model.dart';

part 'survey_statistics_model.g.dart';

@HiveType(typeId: 6)
class StatisticsModel extends HiveObject {
  @HiveField(0)
  final int homes;
  @HiveField(1)
  final int entries;
  @HiveField(2)
  final double completedPercent;
  @HiveField(3)
  final double duration;
  @HiveField(4)
  final List<StatisticDayModel> days;

  StatisticsModel({
    required this.homes,
    required this.entries,
    required this.completedPercent,
    required this.duration,
    required this.days,
  });

  factory StatisticsModel.fromEntity(Statistic entity) {
    return StatisticsModel(
      homes: entity.entries,
      entries: entity.entries,
      completedPercent: entity.completedPercent,
      duration: entity.duration,
      days: entity.days.map((s) => StatisticDayModel.fromEntity(s)).toList(),
    );
  }

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      homes: json['homes'] ?? 0,
      entries: json['entries'] ?? 0,
      completedPercent: json['completed_percentage'] ?? 0,
      duration: json['duration_seconds'] ?? '0',
      days: json['days'] != null
          ? List<StatisticDayModel>.from(
              json['days'].map((x) => StatisticDayModel.fromJson(x)))
          : [],
    );
  }

  Statistic toEntity() {
    return Statistic(
      homes: homes,
      entries: entries,
      completedPercent: completedPercent,
      duration: duration,
      days: days.map((day) => day.toEntity()).toList(),
    );
  }

  factory StatisticsModel.empty() {
    return StatisticsModel(
      homes: 0,
      entries: 0,
      completedPercent: 0,
      duration: 0,
      days: [],
    );
  }
}
