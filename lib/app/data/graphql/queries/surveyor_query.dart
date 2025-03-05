class SurveyorQuery {
  static String surveyor = r'''
    query PollsterHome($id: ID!){
      pollsterHome(id: $id){
        totalEntries
        lastSurvey
      }
    }
  ''';
}