import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../services/cache_storage_service.dart';

class GraphQLConfig {
  static ValueNotifier<GraphQLClient> initializeClient() {
    final String? token = Get.find<CacheStorageService>().token;

    final httpClient = TimeoutHttpClient(timeout: const Duration(seconds: 30));

    final httpLink = HttpLink(
      'https://chiguiro.proyen.co:7701/pond',
      defaultHeaders: {
        'Authorization': 'Bearer $token',
      },
      httpClient: httpClient,
    );

    final link = Link.from([httpLink]);

    return ValueNotifier(
      GraphQLClient(
        link: link,
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

class TimeoutHttpClient extends http.BaseClient {
  final Duration timeout;
  final http.Client _inner;

  TimeoutHttpClient({required this.timeout}) : _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      return await _inner.send(request).timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            'The request timed out after $timeout',
            timeout,
          );
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}