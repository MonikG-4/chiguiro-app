import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/error/failures/failure.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/i_statistic_repository.dart';
import '../../domain/repositories/i_pending_survey_repository.dart';

class StatisticController extends GetxController {
  final IStatisticRepository repository;
  final IPendingSurveyRepository pendingRepository;
  late final AuthStorageService _storageService;

  StatisticController(this.repository, this.pendingRepository);

  final isLoading = false.obs;
  final isError = false.obs;
  final errorMessage = ''.obs;

  final statistics = Rxn<Statistic>();

  // Datos para la gráfica
  final values = <double>[].obs;
  final weekDays = <String>[].obs;
  final pendingCount = 0.obs;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<AuthStorageService>();

    MessageHandler.setupSnackbarListener(message);
    fetchStatistics();
    fetchPendingCount();
  }

  String get formattedDuration {
    final durationSeconds = statistics.value?.duration ?? 0;
    final duration = Duration(seconds: durationSeconds.toInt());

    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  Future<void> fetchStatistics() async {
    isLoading.value = true;
    isError.value = false;

    try {
      final statisticResult =
          await repository.fetchStatistics(_storageService.authResponse!.id);
      statisticResult.fold(
        (failure) {
          _showMessage(
              'Error',
              _mapFailureToMessage(failure).replaceAll("Exception:", ""),
              'error');
        },
        (data) {
          statistics.value = data;
          // Mapear datos para el gráfico
          final days = data.days;

          values.assignAll(days.map((e) => e.entries.toDouble()).toList().reversed);
          weekDays.assignAll(
            days.map((e) {
              final fullDayName = DateFormat.EEEE('es_CO').format(e.date).capitalizeFirst!;
              final dayName = fullDayName.length > 6
                  ? '${fullDayName.substring(0, 6)}..'
                  : fullDayName;
              final shortDate = DateFormat('dd/MM').format(e.date);
              return '$dayName\n$shortDate';
            }).toList().reversed,
          );
        },
      );
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      print('Error fetching statistics: $errorMessage');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPendingCount() async {
    try {
      final result = await pendingRepository.fetchSurveys(_storageService.authResponse!.id);
      result.fold(
            (failure) => pendingCount.value = 0,
            (data) => pendingCount.value = data.length,
      );
    } catch (_) {
      pendingCount.value = 0;
    }
  }


  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return failure.message;
      case NetworkFailure _:
        return 'Sin conexión a internet. Verifica tu conexión.';
      case CacheFailure _:
        return 'No hay datos almacenados. Conecta a internet para obtener datos.';
      default:
        return failure.message;
    }
  }

  void _showMessage(String title, String msg, String state) {
    message.update((val) {
      val?.title = title;
      val?.message = msg;
      val?.state = state;
    });
  }
}
