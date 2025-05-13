import 'dart:async';

import 'package:get/get.dart';
import 'package:dartz/dartz.dart';

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
    String errorSendingDataMessage = 'Error al enviar los datos',
    String unknownErrorMessage = 'Error desconocido',
  }) async {

    if (!_connectivityService.isStableConnection.value) {
      return Left(NetworkFailure(offlineErrorMessage));
    }

    try {
      final result = await request();

      return Right(onSuccess(result));
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
    if (_connectivityService.isConnected.value) {
      try {
        final result = await request();

        final data = onSuccess(result);
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
