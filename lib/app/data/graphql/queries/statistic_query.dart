class StatisticQuery {

  static String statistics = r'''
    query PollsterStatistic($pollsterId: Long!) {
      pollsterStatistic2(pollsterId: $pollsterId) {
        homes
        entries
        completed_percentage
        duration_seconds
        days{
          date
          entries
        }
      }
    }
  ''';
}