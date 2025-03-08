import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/exceptions/exceptions.dart';
import '../../../core/error/failures/failure.dart';
import '../../../core/network/network_request_interceptor.dart';
import '../../../core/services/connectivity_service.dart';

abstract class BaseRepository {
  final NetworkRequestInterceptor _interceptor =
      Get.find<NetworkRequestInterceptor>();
  final ConnectivityService _connectivityService = Get.find();

  /// Procesa una solicitud GraphQL con manejo de conectividad y errores
  Future<QueryResult> processRequest(
      Future<QueryResult> Function() request) async {
    return await _interceptor.handleRequest(request);
  }

  /// Envuelve una solicitud GraphQL en un Either para manejo de éxito/error
  Future<Either<Failure, T>> safeApiCall<T>({
    required Future<QueryResult> Function() request,
    required T Function(Map<String, dynamic> data) onSuccess,
    required String dataKey,
    String offlineErrorMessage = 'Sin conexión a internet',
    String unknownErrorMessage = 'Error desconocido',
  }) async {
    if (!_connectivityService.isConnected.value) {
      return Left(NetworkFailure(offlineErrorMessage));
    }

    try {
      final result = await processRequest(request);

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.firstOrNull;
        return Left(ServerFailure(error?.message ?? unknownErrorMessage));
      }

      if (result.data == null || result.data![dataKey] == null) {
        return Left(UnknownFailure(unknownErrorMessage));
      }

      return Right(onSuccess(result.data!));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Maneja operaciones con almacenamiento local cuando está sin conexión
  Future<Either<Failure, T>> safeApiCallWithCache<T>({
    required Future<QueryResult> Function() request,
    required T Function(Map<String, dynamic> data) onSuccess,
    required String dataKey,
    required Future<T> Function() getCacheData,
    required Function(T data) saveToCache,
    String unknownErrorMessage = 'Error desconocido',
  }) async {
    if (_connectivityService.isConnected.value) {
      try {
        final result = await processRequest(request);

        if (result.hasException) {
          final error = result.exception?.graphqlErrors.firstOrNull;
          return Left(ServerFailure(error?.message ?? unknownErrorMessage));
        }

        if (result.data == null || result.data![dataKey] == null) {
          return Left(UnknownFailure(unknownErrorMessage));
        }

        final data = onSuccess(result.data!);
        saveToCache(data);
        return Right(data);
      } on Exception catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      try {
        final cachedData = await getCacheData();
        return Right(cachedData);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    }
  }
}
