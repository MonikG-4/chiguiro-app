class SurveyRespondedQuery {
  static String pollsterStatisticHome = r'''
    query PollsterStatisticHome($homeCode: String!, $pollsterId: Long!) {
      pollsterStatisticHome(homeCode: $homeCode, pollsterId: $pollsterId) {
        totalEntries
        lastSurvey
        project{
          id
          name
          active
        }
      }
    }
  ''';
}
