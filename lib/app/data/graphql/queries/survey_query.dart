class SurveyQuery {
  static String project = r'''
    query Project($id: Long!) {
      project(id: $id) {
        id
        name
        active
        entriesCount
        geoLocation
        voiceRecorder
      }
    }
  ''';

  static String sections = r'''
    query Sections($projectId: Long!) {
      sections(projectId: $projectId) {
        id
        name
        description
        sort
        questions{
          id
          question
          description
          sort
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
    }
  ''';
}
