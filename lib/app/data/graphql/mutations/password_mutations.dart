class PasswordMutations {
  static String pollsterForgotPassword = r'''
    mutation PollsterForgotPassword($email: String!) {
      pollsterForgotPassword(email: $email)
    }
  ''';

  static String pollsterChangePassword = r'''
    mutation PollsterChangePassword($id: ID!, $password: String!) {
      pollsterChangePassword(id: $id, password: $password)
    }
  ''';
}