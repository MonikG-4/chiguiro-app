import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/graphql_service.dart';
import '../../domain/entities/block_code.dart';
import '../../domain/repositories/i_survey_repository.dart';
import '../graphql/mutations/survey_mutation.dart';
import '../graphql/queries/block_code_query.dart';
import 'base_repository.dart';

class SurveyRepository extends BaseRepository implements ISurveyRepository {
  final GraphQLService _graphqlService = Get.find<GraphQLService>();

  @override
  Future<Either<Failure, bool>> saveSurveyResults(
      Map<String, dynamic> entryInput) async {
    return safeApiCall<bool>(
      request: () =>
          _graphqlService.mutate(
            document: SurveyMutation.entry,
            variables: {
          'input': entryInput,
          },
          ),
      onSuccess: (data) => data['entry'].isNotEmpty,
      dataKey: 'entry',
      unknownErrorMessage: 'No se logró enviar la encuesta, intente nuevamente',
    );
  }

  @override
  Future<Either<Failure, BlockCode>> fecthBlockCode(double latitude,
      double longitude) async {
    return safeApiCall<BlockCode>(
      request: () =>
          _graphqlService.query(
            document: BlockCodeQuery.blockCode,
            variables: {
              "latitude": latitude,
              "longitude": longitude
            },
          ),
      onSuccess: (data) =>
          BlockCode.fromJson(data['geoData']),
      dataKey: 'geoData',
      unknownErrorMessage: 'No se encontraron datos para esta ubicación.',
    );
  }
}