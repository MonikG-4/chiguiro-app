class StatisticDay {
  final DateTime date;
  final int entries;

  StatisticDay({
    required this.date,
    required this.entries,
  });

  @override
  String toString() {
    return 'StatisticDay(date: $date, entries: $entries)';
  }
}