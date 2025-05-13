import 'package:graphql_flutter/graphql_flutter.dart';

import '../error/exceptions/exceptions.dart';
import '../network/graphql_client_provider.dart';

class GraphQLService {
  late final GraphQLClient _client;

  GraphQLService({required GraphQLClientProvider clientProvider}) {
    _client = clientProvider.getClient();
  }

  Future<Map<String, dynamic>> query({
    required String document,
    Map<String, dynamic>? variables,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(document),
        variables: variables!,
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    return _handleResult(result);
  }

  Future<Map<String, dynamic>> mutate({
    required String document,
    Map<String, dynamic>? variables,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(document),
        variables: variables!,
        fetchPolicy: FetchPolicy.noCache,
      ),
    );
    return _handleResult(result);
  }

  Map<String, dynamic> _handleResult(QueryResult result) {
    if (result.hasException) {
      final e = result.exception!;
      if (e.graphqlErrors.isNotEmpty) {
        final first = e.graphqlErrors.first;
        final type = first.extensions?['classification'];
        final message = first.message;

        if (type == 'BAD_REQUEST') throw CheckException(message);
        if (type == 'UNAUTHORIZED') throw GateException(message);

        throw Exception(message);
      } else if (e.linkException != null) {
        throw AppNetworkException(e.linkException.toString());
      }
    }
    return result.data ?? {};
  }
}
