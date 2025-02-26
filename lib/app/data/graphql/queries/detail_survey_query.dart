class DetailSurveyQuery {
  static String entries = r'''
    query PollsterEntries($id: ID!, $Page: PageInput!) {
      pollsterEntries(id: $id, page: $Page) {
        total
        elements{
          createdOn
          id
          statistic{
            answerPercentage
            completed
          }
        } 
      }
    }

  ''';
}