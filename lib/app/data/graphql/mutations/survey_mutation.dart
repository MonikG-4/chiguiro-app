class SurveyMutation {
  static String entry = r'''
    mutation entry( $input: EntryInput!) {
      entry(input: $input) {
        id
      }
    }
  ''';
}