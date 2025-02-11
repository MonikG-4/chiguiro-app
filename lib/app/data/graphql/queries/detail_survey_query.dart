class DetailSurveyQuery {
  static String entries = r'''
    query Entries($projectId: Long!, $Page: PageInput!) {
      entries(projectId: $projectId, page: $Page) {
        elements{
          id
          createdOn
          statistic{
            answerPercentage
            completed
          }
        }
      }
    }
  ''';
}