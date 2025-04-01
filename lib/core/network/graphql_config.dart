import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/cache_storage_service.dart';

class GraphQLConfig {
  static ValueNotifier<GraphQLClient> initializeClient() {
    final String? token = Get.find<CacheStorageService>().token;

    // Cliente HTTP con timeout de 30 segundos
    final httpClient = TimeoutHttpClient(const Duration(seconds: 30));

    final HttpLink httpLink = HttpLink(
      'https://chiguiro.proyen.co:7701/pond',
      defaultHeaders: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      httpClient: httpClient,
    );

    final Link link = Link.from([httpLink]);

    return ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: null),
        defaultPolicies: DefaultPolicies(
          query: Policies(fetch: FetchPolicy.noCache),
          mutate: Policies(fetch: FetchPolicy.noCache),
        ),
      ),
    );
  }
}

// Cliente HTTP con timeout extendido
class TimeoutHttpClient extends IOClient {
  TimeoutHttpClient(Duration timeout)
      : super(HttpClient()
    ..idleTimeout = timeout
    ..connectionTimeout = timeout);

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) {
    return super.send(request).timeout(const Duration(seconds: 30));
  }
}
