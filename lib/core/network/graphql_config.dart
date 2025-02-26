import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:get/get.dart';

import '../services/cache_storage_service.dart';


class GraphQLConfig {

  static ValueNotifier<GraphQLClient> initializeClient() {
    final String? token = Get.find<CacheStorageService>().token;
    HttpLink httpLink = HttpLink(
      'https://chiguiro.proyen.co:7701/pond',
      defaultHeaders: {
        'Authorization': 'Bearer $token',
      },
    );
    return ValueNotifier(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }
}
