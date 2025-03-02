class LoginQuery {
  static String pollsterLogin = r'''
    query PollsterLogin($email: String!, $password: String!) {
      pollsterLogin(email: $email, password: $password) {
        id
        name
        surname
        accessToken
      }
    }
  ''';
}