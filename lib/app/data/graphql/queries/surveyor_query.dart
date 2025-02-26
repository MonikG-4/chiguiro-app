class SurveyorQuery {
  static String surveyor = r'''
    query Pollster($id: Long!) {
      pollster(id: $id) {
        id
        name
        surname
        statistic{
          totalEntries
          totalCompleted
          totalUncompleted
          completedPercentage
        }
      }
    }
  ''';
}