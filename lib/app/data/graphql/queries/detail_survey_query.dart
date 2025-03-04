class DetailSurveyQuery {

  static String statistics = r'''
    query PollsterStatistic($pollsterId: Long!, $projectId: Long!) {
      pollsterStatistic(pollsterId: $pollsterId, projectId: $projectId) {
        totalEntries
        totalCompleted
        totalUncompleted
        completedPercentage
        lastSurvey
      }
    }
  ''';

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