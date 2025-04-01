import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService extends GetxService {
  late ValueNotifier<GraphQLClient> client;

  Future<GraphQLService> init() async {
    client = _initializeClient();
    return this;
  }

  ValueNotifier<GraphQLClient> _initializeClient() {
    final HttpLink httpLink = HttpLink(
      'https://chiguiro.proyen.co:7701/pond',
      defaultHeaders: {
        'Authorization': 'Bearer TU_TOKEN',
        'Content-Type': 'application/json',
      },
    );

    return ValueNotifier(
      GraphQLClient(
        link: Link.from([httpLink]),
        cache: GraphQLCache(store: null),
        defaultPolicies: DefaultPolicies(
          query: Policies(fetch: FetchPolicy.noCache),
          mutate: Policies(fetch: FetchPolicy.noCache),
        ),
      ),
    );
  }
}


