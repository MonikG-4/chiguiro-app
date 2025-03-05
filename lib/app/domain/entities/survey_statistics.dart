class SurveyStatistics {
  final int totalEntries;
  final int totalCompleted;
  final int totalUncompleted;
  final String completedPercentage;
  final DateTime lastSurvey;

  SurveyStatistics({
    required this.totalEntries,
    required this.totalCompleted,
    required this.totalUncompleted,
    required this.completedPercentage,
    required this.lastSurvey,
  });
}