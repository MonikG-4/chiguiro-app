class DetailSurveyQuery {
  static String entries = r'''
    query PollsterEntries($id: ID!, $projectId: Long!, $page: PageInput!) {
      pollsterEntries(id: $id, projectId: $projectId, page: $page) {
        total
        elements {
          createdOn
          id
          statistic {
            answerPercentage
            completed
          }
        }
      }
    }

  ''';
}