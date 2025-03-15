import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  late final Connectivity _connectivity;
  final RxBool isConnected = false.obs;
  final RxBool isStableConnection = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final Completer<void> _initCompleter = Completer<void>();

  final List<MapEntry<int, Function()>> _onConnectedCallbacks = [];
  final List<MapEntry<int, Function()>> _onDisconnectedCallbacks = [];

  ConnectivityService();

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
      isStableConnection.value = false;
      await Future.delayed(const Duration(seconds: 2));
      isStableConnection.value = await hasInternetConnection();
      await _updateConnectionStatus(result);
    });
  }

  Future<void> waitForStableConnection() async {
    while (!isStableConnection.value) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
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
      if (newConnectionStatus) {
        _triggerCallbacks(newConnectionStatus);
      }
    }
  }

  Future<void> _triggerCallbacks(bool isConnected) async {
    final callbacks =
        isConnected ? _onConnectedCallbacks : _onDisconnectedCallbacks;
    callbacks.sort((a, b) => a.key.compareTo(b.key));
    for (var callback in callbacks) {
      await callback.value();
    }
  }

  void addCallback(bool onConnected, int priority, Function() callback) {
    final entry = MapEntry(priority, callback);
    if (onConnected) {
      _onConnectedCallbacks.add(entry);
    } else {
      _onDisconnectedCallbacks.add(entry);
    }
  }

  void removeCallback(bool onConnected, Function() callback) {
    if (onConnected) {
      _onConnectedCallbacks.removeWhere((entry) => entry.value == callback);
    } else {
      _onDisconnectedCallbacks.removeWhere((entry) => entry.value == callback);
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
