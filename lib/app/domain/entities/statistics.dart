import 'statistic_day.dart';

class Statistic {
  final int homes;
  final int entries;
  final double completedPercent;
  final double duration;

  final List<StatisticDay>  days;

  Statistic({
    required this.homes,
    required this.entries,
    required this.completedPercent,
    required this.duration,
    required this.days,
  });

  @override
  String toString() {
    return 'SurveyStatistics(homes: $homes, entries: $entries, completedPercent: $completedPercent, duration: $duration, days: $days)';
  }
}