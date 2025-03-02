import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/mutations/password_mutations.dart';
import '../graphql/queries/login_query.dart';

class AuthProvider {
  final GraphQLClient client;

  AuthProvider(this.client);

  Future<QueryResult> login(String email, String password) async {
    try {
      final QueryOptions options = QueryOptions(
        document: gql(LoginQuery.pollsterLogin),
        variables: {
          "email": email,
          "password": password,
        },
      );
      final result = await client.query(options);

      return result;
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  Future<QueryResult> forgotPassword(String email) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(PasswordMutations.pollsterForgotPassword),
        variables: {
          "email": email,
        },
      );

      final result = await client.mutate(options);
      return result;
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }
}