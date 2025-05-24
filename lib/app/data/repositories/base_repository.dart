import 'dart:async';

import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../core/error/exceptions/exceptions.dart';
import '../../../core/error/failures/failure.dart';
import '../../../core/services/connectivity_service.dart';

abstract class BaseRepository {

  final ConnectivityService _connectivityService = Get.find();

  /// Envuelve una solicitud GraphQL en un Either para manejo de éxito/error
  Future<Either<Failure, T>> safeApiCall<T>({
    required Future<Map<String, dynamic>> Function() request,
    required T Function(Map<String, dynamic> data) onSuccess,
    required String dataKey,
    String offlineErrorMessage = 'Sin conexión a internet',
    String unknownErrorMessage = 'Error desconocido',
  }) async {
    await _connectivityService.waitForConnection();

    if (!_connectivityService.isOnline) {
      return Left(NetworkFailure(offlineErrorMessage));
    }

    try {
      final result = await request();

      if (!result.containsKey(dataKey) || result[dataKey] == null) {
        return Left(UnknownFailure(unknownErrorMessage));
      }

      return Right(onSuccess(result));
    } on CheckException catch (e) {
      return Left(ValidationFailure(e.message));
    } on GateException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Error de red'));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }


  /// Maneja operaciones con almacenamiento local cuando está sin conexión
  Future<Either<Failure, T>> safeApiCallWithCache<T>({
    required Future<Map<String, dynamic>> Function() request,
    required T Function(Map<String, dynamic> data) onSuccess,
    required String dataKey,
    required Future<T> Function() getCacheData,
    required Function(T data) saveToCache,
    String unknownErrorMessage = 'Error desconocido',
  }) async {
    await _connectivityService.waitForConnection();

    if (_connectivityService.isOnline) {
      try {
        final result = await request();

        if (!result.containsKey(dataKey) || result[dataKey] == null) {
          return Left(UnknownFailure(unknownErrorMessage));
        }

        final data = onSuccess(result);
        saveToCache(data);
        return Right(data);
      } on CheckException catch (e) {
        return Left(ValidationFailure(e.message));
      } on GateException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message ?? 'Error de red'));
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
