import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';


class ConnectivityService extends GetxService {

  late final Connectivity _connectivity;
  final RxBool isConnected = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

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
  }

  void _setupConnectivityStream() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(dynamic result) {
    bool newConnectionStatus;

    if (result is List<ConnectivityResult>) {
      newConnectionStatus = result.isNotEmpty && result.any((r) => r != ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      newConnectionStatus = result != ConnectivityResult.none;
    } else {
      return;
    }

    if (isConnected.value != newConnectionStatus) {
      isConnected.value = newConnectionStatus;
      _triggerCallbacks(newConnectionStatus);
    }
  }


  void _triggerCallbacks(bool isConnected) {
    final callbacks = isConnected ? _onConnectedCallbacks : _onDisconnectedCallbacks;
    for (var callback in callbacks) {
      callback();
    }
  }

  void addCallback(bool onConnected, Function() callback) {
    if (onConnected) {
      _onConnectedCallbacks.add(callback);
    } else {
      _onDisconnectedCallbacks.add(callback);
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
