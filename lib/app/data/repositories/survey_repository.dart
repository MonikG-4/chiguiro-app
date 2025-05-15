import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/error/failures/failure.dart';
import '../../../core/services/graphql_service.dart';
import '../../../core/services/sync_task_storage_service.dart';
import '../../domain/entities/block_code.dart';
import '../../domain/repositories/i_survey_repository.dart';
import '../graphql/queries/block_code_query.dart';
import 'base_repository.dart';

class SurveyRepository extends BaseRepository implements ISurveyRepository {
  final SyncTaskStorageService _syncTaskStorageService = Get.find();
  final GraphQLService _graphqlService = Get.find<GraphQLService>();

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchSurveys(
      int surveyorId) async {
    try {
      final tasks = _syncTaskStorageService.getPendingTasks(surveyorId);
      final result = tasks.map((task) =>
      {
        'surveyName': task.surveyName,
        'id': task.id,
        'payload': task.payload,
      }).toList();

      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Map<String, dynamic>> saveSurveyResults(
      Map<String, dynamic> entryInput) async {
    try {
      final response = await http.post(
        Uri.parse("https://chiguiro.proyen.co:7701/pond"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "query": """
          mutation entry(\$input: EntryInput!) {
            entry(input: \$input) {
              id
            }
          }
        """,
          "variables": {
            "input": entryInput,
          },
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Captura errores del servidor (campo "errors" en GraphQL)
        if (data['errors'] != null) {
          final errorMessage = data['errors'][0]['message'] ??
              'Error desconocido del servidor';
          throw Exception('Error del servidor: $errorMessage');
        }

        return data;
      } else {
        throw Exception(
            "Error HTTP: ${response.statusCode} - ${response.body}");
      }
    } on http.ClientException catch (e) {
      throw Exception("Error de red (ClientException): ${e.message}");
    } on TimeoutException {
      throw Exception("Error de red: conexión agotada");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
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