class SurveyQuery {
  static String project = r'''
    query Project($id: Long!) {
      project(id: $id) {
        id
        name
        active
        entriesCount
      }
    }
  ''';

  static String questions = r'''
    query Questions($projectId: Long!) {
      questions(projectId: $projectId) {
        id
        question
        section{
          id
          name
          sort
        }
        sort
        active
        type
        mandatory
        meta
        meta2
        anchorMax
        anchorMin
        scaleMax
        scaleMin
        jumpers {
          value
          questionNumber
        }
      }
    }
  ''';
}
