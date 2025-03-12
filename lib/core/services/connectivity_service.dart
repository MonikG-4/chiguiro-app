import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'sync_service.dart';

class ConnectivityService extends GetxService {
  final SyncService _syncService;

  late final Connectivity _connectivity;
  final RxBool isConnected = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final Completer<void> _initCompleter = Completer<void>();

  final List<Function()> _onConnectedCallbacks = [];
  final List<Function()> _onDisconnectedCallbacks = [];

  ConnectivityService(this._syncService);

  @override
  void onInit() {
    super.onInit();
    _connectivity = Connectivity();
    _initConnectivity();
    _setupConnectivityStream();
  }

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(result);
    _initCompleter.complete();
  }

  Future<void> waitForInitialization() => _initCompleter.future;

  void _setupConnectivityStream() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) async {
      await _updateConnectionStatus(result);
    });
  }

  Future<bool> hasInternetConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('https://www.google.com'),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } on http.ClientException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateConnectionStatus(dynamic result) async {
    bool newConnectionStatus = result != ConnectivityResult.none;

    if (newConnectionStatus) {
      newConnectionStatus = await hasInternetConnection();
    }

    if (isConnected.value != newConnectionStatus) {
      isConnected.value = newConnectionStatus;
      if (newConnectionStatus && !_syncService.isSyncing.value) {
        await _syncService.syncPendingTasks();
      }
      _triggerCallbacks(newConnectionStatus);
    }
  }

  void _triggerCallbacks(bool isConnected) {
    final callbacks =
        isConnected ? _onConnectedCallbacks : _onDisconnectedCallbacks;
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
