class SurveyQuery {
  static String pollstersProjectByPollster = r'''
    query PollsterProject($pollsterId: Long!){
      pollstersProjectByPollster(pollsterId: $pollsterId){
        project{
          id
          name
          active
          entriesCount
          geoLocation
          voiceRecorder
          sections{
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
      }
    }
  ''';
}
