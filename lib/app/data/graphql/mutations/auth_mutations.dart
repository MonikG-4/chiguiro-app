class AuthMutations {
  static String forgotPassword = r'''
    mutation forgotPassword($email: String!) {
      forgotPassword(email: $email)
    }
  ''';
}