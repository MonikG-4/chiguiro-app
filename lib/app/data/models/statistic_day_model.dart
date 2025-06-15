import 'package:hive/hive.dart';

import '../../domain/entities/statistic_day.dart';

part 'statistic_day_model.g.dart';

@HiveType(typeId: 10)
class StatisticDayModel extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int entries;

  StatisticDayModel({
    required this.date,
    required this.entries,
  });

  factory StatisticDayModel.fromEntity(StatisticDay statisticDay) {
    return StatisticDayModel(
      date: statisticDay.date,
      entries: statisticDay.entries,
    );
  }

  factory StatisticDayModel.fromJson(Map<String, dynamic> json) {
    return StatisticDayModel(
      date: DateTime.parse(json['date']),
      entries: json['entries'],
    );
  }

  StatisticDay toEntity() {
    return StatisticDay(
      date: date,
      entries: entries,
    );
  }
}