import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import '../../app/bindings/dashboard_surveyor_binding.dart';
import '../../app/bindings/detail_survey_binding.dart';
import '../../app/presentation/controllers/dashboard_surveyor_controller.dart';
import '../../app/presentation/controllers/detail_survey_controller.dart';
import '../values/routes.dart';
import 'sync_service.dart';

class ConnectivityService extends GetxService {
  late final Connectivity _connectivity;
  final SyncService _syncService = Get.find();

  final RxBool isConnected = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final Completer<void> _initCompleter = Completer<void>();

  final List<Function()> _onConnectedCallbacks = [];
  final List<Function()> _onDisconnectedCallbacks = [];

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _initConnectivity();
    _setupConnectivityStream();
  }

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    if (!_initCompleter.isCompleted) {
      _initCompleter.complete();
    }
  }

  Future<void> waitForInitialization() => _initCompleter.future;

  void _setupConnectivityStream() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(dynamic result) async {
    bool newConnectionStatus = result is ConnectivityResult
        ? result != ConnectivityResult.none
        : result.isNotEmpty && result.any((r) => r != ConnectivityResult.none);

    if (isConnected.value != newConnectionStatus) {
      isConnected.value = newConnectionStatus;

      if (newConnectionStatus) {
        print('Conexión restablecida, sincronizando...');
        await _syncService.syncPendingTasks();
        refreshCurrentController();
      } else {
        print('Sin conexión, cargando datos locales...');
        _triggerCallbacks(false);
      }
    }
  }

  Future<void> refreshCurrentController() async {
    final currentRoute = Get.currentRoute;

    switch (currentRoute) {
      case Routes.DASHBOARD_SURVEYOR:
        if (Get.isRegistered<DashboardSurveyorController>()) {
          await Get.delete<DashboardSurveyorController>();
          DashboardSurveyorBinding().dependencies();
          Get.find<DashboardSurveyorController>().fetchSurveys();
        }
        break;

      case Routes.SURVEY_DETAIL:
        if (Get.isRegistered<DetailSurveyController>()) {
          await Get.delete<DetailSurveyController>();
          DetailSurveyBinding().dependencies();
          Get.find<DetailSurveyController>().fecthDetailSurvey();
        }
        break;

    // Añadir más casos según tus rutas y bindings
      default:
        print('No se encontró binding para la ruta: $currentRoute');
    }
  }




  void monitorConnection(Function fetchOnlineData, Function loadCachedData) {
    ever(isConnected, (bool connected) {
      if (connected) {
        fetchOnlineData();
      } else {
        loadCachedData();
      }
      Get.forceAppUpdate(); // Fuerza la actualización de la UI
    });

    if (isConnected.value) {
      fetchOnlineData();
    } else {
      loadCachedData();
    }
  }


  void _triggerCallbacks(bool isConnected) {
    print('Connection status changed: $isConnected');
    final callbacks = isConnected ? _onConnectedCallbacks : _onDisconnectedCallbacks;
    print('Triggering ${callbacks.length} callbacks');
    for (var callback in callbacks) {
      callback();
    }
  }

  void addCallback(bool onConnected, Function() callback) {
    if (onConnected) {
      if (!_onConnectedCallbacks.contains(callback)) {
        _onConnectedCallbacks.add(callback);
      }
    } else {
      if (!_onDisconnectedCallbacks.contains(callback)) {
        _onDisconnectedCallbacks.add(callback);
      }
    }
  }

  void removeCallback(bool onConnected, Function() callback) {
    if (onConnected) {
      _onConnectedCallbacks.remove(callback);
    } else {
      _onDisconnectedCallbacks.remove(callback);
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
