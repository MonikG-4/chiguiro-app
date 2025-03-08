import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../services/cache_storage_service.dart';

class GraphQLConfig {
  static ValueNotifier<GraphQLClient> initializeClient() {
    final String? token = Get.find<CacheStorageService>().token;

    final httpClient = _TimeoutClient(const Duration(seconds: 30));

    HttpLink httpLink = HttpLink(
      'https://chiguiro.proyen.co:7701/pond',
      defaultHeaders: {
        'Authorization': 'Bearer $token',
      },
      httpClient: httpClient,
    );

    return ValueNotifier(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: null),
        defaultPolicies: DefaultPolicies(
          query: Policies(
            fetch: FetchPolicy.noCache,
          ),
          mutate: Policies(
            fetch: FetchPolicy.noCache,
          ),
        ),
      ),
    );
  }
}

class _TimeoutClient extends http.BaseClient {
  final Duration timeout;
  final http.Client _inner;

  _TimeoutClient(this.timeout) : _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).timeout(timeout);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}