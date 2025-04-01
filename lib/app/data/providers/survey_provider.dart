import 'dart:async';

import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../core/services/graphql_service.dart';
import '../graphql/mutations/survey_mutation.dart';

class SurveyProvider {
  final GraphQLClient client = Get.find<GraphQLService>().client.value;

  Future<QueryResult> saveSurveyResults(Map<String, dynamic> entryInput) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(SurveyMutation.entry),
        variables: {'input': entryInput},
      );

      final result = await client.mutate(options);

      return result;
    } catch (e) {
      throw Exception('Error al guardar las respuestas de la encuesta: $e');
    }
  }
}
