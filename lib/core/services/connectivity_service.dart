import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class CallbackEntry {
  final int priority;
  final Future<void> Function() callback;
  final String? id;

  const CallbackEntry(this.priority, this.callback, [this.id]);
}

class ConnectivityService extends GetxService with WidgetsBindingObserver {
  static const _retryDelay = Duration(milliseconds: 800);
  static const _checkUrl = 'https://www.google.com';

  late final Connectivity _connectivity;
  late final http.Client _httpClient;

  final RxBool _isOnline = true.obs;
  final Completer<void> _initCompleter = Completer<void>();
  final _onConnectedCallbacks = <CallbackEntry>[];
  final _onDisconnectedCallbacks = <CallbackEntry>[];

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounceTimer;
  bool _isChecking = false;

  bool get isOnline => _isOnline.value;
  RxBool get isOnlineStream => _isOnline;

  @override
  Future<void> onInit() async {
    super.onInit();
    _connectivity = Connectivity();
    _httpClient = http.Client();

    WidgetsBinding.instance.addObserver(this);

    await _checkInitialConnection();
    _setupListener();
    _initCompleter.complete();
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    await _updateConnection(result);
  }

  void _setupListener() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _updateConnection(results);
      });
    });
  }

  Future<void> _updateConnection(List<ConnectivityResult> results) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final hasBasicConnectivity = !results.contains(ConnectivityResult.none);
      var hasInternet = false;

      if (hasBasicConnectivity) {
        hasInternet = await _checkInternet();

        if (!hasInternet) {
          await Future.delayed(_retryDelay);
          hasInternet = await _checkInternet();
        }
      }

      if (_isOnline.value != hasInternet) {
        _isOnline.value = hasInternet;
        await _runCallbacks(hasInternet);
      }
    } finally {
      _isChecking = false;
    }
  }

  /// 🔍 Valida acceso real a internet
  Future<bool> _checkInternet() async {
    try {
      // 1️⃣ Chequeo rápido con DNS lookup (mejor en iOS)
      final result = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 2));
      if (result.isEmpty || result.first.rawAddress.isEmpty) return false;

      // 2️⃣ HEAD a Google (confirma salida real)
      final response = await _httpClient
          .head(Uri.parse(_checkUrl))
          .timeout(const Duration(seconds: 3));

      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      Get.log('Check internet failed: $e', isError: true);
      return false;
    }
  }

  Future<void> _runCallbacks(bool isConnected) async {
    final callbacks =
    isConnected ? _onConnectedCallbacks : _onDisconnectedCallbacks;
    if (callbacks.isEmpty) return;

    for (final entry in [...callbacks]..sort((a, b) => a.priority.compareTo(b.priority))) {
      try {
        await entry.callback();
      } catch (e) {
        Get.log('Error en callback ${entry.id ?? "sin_id"}: $e', isError: true);
      }
    }
  }

  Future<void> waitForInit() => _initCompleter.future;

  Future<bool> forceCheck() async {
    await waitForInit();
    final result = await _connectivity.checkConnectivity();
    await _updateConnection(result);
    return isOnline;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 500), forceCheck);
    }
  }

  Future<bool> waitForConnection(
      [Duration timeout = const Duration(milliseconds: 500)]) async {
    await waitForInit();
    if (isOnline) return true;

    final completer = Completer<bool>();
    Timer? timer;
    late final StreamSubscription sub;

    timer = Timer(timeout, () {
      sub.cancel();
      if (!completer.isCompleted) completer.complete(false);
    });

    sub = _isOnline.listen((connected) {
      if (connected) {
        timer?.cancel();
        sub.cancel();
        if (!completer.isCompleted) completer.complete(true);
      }
    });

    return completer.future;
  }

  void addCallback(bool onConnected, Future<void> Function() callback,
      {int priority = 0, String? id}) {
    final list = onConnected ? _onConnectedCallbacks : _onDisconnectedCallbacks;
    if (id != null) list.removeWhere((e) => e.id == id);
    list.add(CallbackEntry(priority, callback, id));
  }

  void removeCallback(bool onConnected, String id) {
    final list = onConnected ? _onConnectedCallbacks : _onDisconnectedCallbacks;
    list.removeWhere((e) => e.id == id);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    _httpClient.close();
    _onConnectedCallbacks.clear();
    _onDisconnectedCallbacks.clear();
    super.onClose();
  }
}
