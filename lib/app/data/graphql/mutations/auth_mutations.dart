class AuthMutations {
  static String login = r'''
    mutation login($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        accessToken
        createdOn
        expiredOn
        active
        user {
          id
          name
          surname
        }
      }
    }
  ''';

  static String forgotPassword = r'''
    mutation forgotPassword($email: String!) {
      forgotPassword(email: $email)
    }
  ''';
}