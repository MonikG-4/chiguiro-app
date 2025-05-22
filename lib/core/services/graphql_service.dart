import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../app/presentation/controllers/session_controller.dart';
import '../error/exceptions/exceptions.dart';
import '../network/graphql_client_provider.dart';

class GraphQLService {
  late final GraphQLClient _client;
  final SessionController _sessionController = Get.find();

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
          queryRequestTimeout: const Duration(seconds: 1000)),
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
          queryRequestTimeout: const Duration(seconds: 1000)),
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
        if (type == 'UNAUTHORIZED') {
          _sessionController.logout();
          throw GateException(message);
        }
        throw Exception('Error de peticion: $message (Tipo: $type)');
      } else if (e.linkException != null) {
        final linkEx = e.linkException!;

        String errorMessage = 'Ha ocurrido un problema con la red.';
        if (linkEx is ServerException) {
          errorMessage = 'Error de servidor: conexion interrumpida';
        } else if (linkEx is NetworkException) {
          errorMessage = 'Conexión fallida: revisa tu conexion';
        }
        throw NetworkException(message: errorMessage, originalException: linkEx, uri: null);
      } else {
        throw Exception('Problema desconocido: ${e.toString()}');
      }
    }
    return result.data ?? {};
  }
}
