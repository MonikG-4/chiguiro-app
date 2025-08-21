class LoginQuery {
  static String pollsterLogin = r'''
    query PollsterLogin($email: String!, $password: String!, $appCode: String) {
      pollsterLogin(email: $email, password: $password, appCode: $appCode) {
        id
        name
        surname
        email
        phone
        accessToken
      }
    }
  ''';
}