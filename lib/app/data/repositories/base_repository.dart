import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../core/network/network_request_interceptor.dart';

abstract class BaseRepository {
  final NetworkRequestInterceptor _interceptor = Get.find<NetworkRequestInterceptor>();

  Future<QueryResult> processRequest(Future<QueryResult> Function() request) async {
    return await _interceptor.handleRequest(request);
  }
}
