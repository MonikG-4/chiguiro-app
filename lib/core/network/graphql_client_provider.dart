import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../services/auth_storage_service.dart';

class GraphQLClientProvider {
  GraphQLClient getClient() {
    final String? token = Get.find<AuthStorageService>().token;
    final httpLink = HttpLink('https://pond.capibara.lat/pond');

    final authLink = AuthLink(
      getToken: () async => token,
    );

    final link = authLink.concat(httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }
}
