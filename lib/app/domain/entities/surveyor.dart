class Surveyor {
  final int totalEntries;
  final String lastSurvey;

  Surveyor({
    required this.totalEntries,
    required this.lastSurvey,
  });

  @override
  String toString() {
    return 'Surveyor(totalEntries: $totalEntries, lastSurvey: $lastSurvey)';
  }
}