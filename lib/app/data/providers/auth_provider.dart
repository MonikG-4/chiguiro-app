import 'package:graphql_flutter/graphql_flutter.dart';

import '../graphql/mutations/auth_mutations.dart';

class AuthProvider {
  final GraphQLClient client;

  AuthProvider(this.client);

  Future<QueryResult> login(String email, String password) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(AuthMutations.login),
        variables: {
          "email": email,
          "password": password,
        },
      );

      final result = await client.mutate(options);
      return result;
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }

  Future<QueryResult> forgotPassword(String email) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(AuthMutations.forgotPassword),
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