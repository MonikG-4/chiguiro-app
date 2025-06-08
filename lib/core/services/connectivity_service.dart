import 'dart:async';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Callback con prioridad para eventos de conectividad
class CallbackEntry {
  final int priority;
  final Future<void> Function() callback;
  final String? id;

  const CallbackEntry(this.priority, this.callback, [this.id]);
}

/// Servicio de conectividad simplificado
class ConnectivityService extends GetxService with WidgetsBindingObserver {
  static const _retryDelay = Duration(milliseconds: 800);
  static const _checkUrl = 'pond.capibara.lat';

  late final Connectivity _connectivity;
  late final http.Client _httpClient;

  final RxBool _isOnline = true.obs;
  final Completer<void> _initCompleter = Completer<void>();
  final List<CallbackEntry> _onConnectedCallbacks = [];
  final List<CallbackEntry> _onDisconnectedCallbacks = [];

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
      final hasNetwork = results.any((result) =>
      result == ConnectivityResult.wifi || result == ConnectivityResult.mobile);

      bool hasInternet = false;

      if (hasNetwork) {
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

  Future<bool> _checkInternet() async {
    final ping = Ping(_checkUrl, count: 5, timeout: 3);
    int received = 0;

    try {
      await for (final event in ping.stream) {
        if (event.response != null) {
          received++;
        }
      }

      return received > 0;
    } catch (e) {
      print('Ping error: $e');
      return false;
    }
  }


  Future<void> _runCallbacks(bool isConnected) async {
    final callbacks = isConnected ? _onConnectedCallbacks : _onDisconnectedCallbacks;
    if (callbacks.isEmpty) return;

    final sorted = List<CallbackEntry>.from(callbacks)
      ..sort((a, b) => a.priority.compareTo(b.priority));

    for (final entry in sorted) {
      try {
        await entry.callback();
      } catch (e) {
        Get.log('Error en callback ${entry.id ?? "sin_id"}: $e', isError: true);
      }
    }
  }

  /// Espera a que el servicio esté listo
  Future<void> waitForInit() => _initCompleter.future;

  /// Fuerza verificación de conectividad
  Future<bool> forceCheck() async {
    await waitForInit();
    final result = await _connectivity.checkConnectivity();
    await _updateConnection(result);
    return isOnline;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Forzar verificación cuando la app vuelve al foreground
    if (state == AppLifecycleState.resumed) {
      // Pequeño delay para que la red se estabilice
      Future.delayed(const Duration(milliseconds: 500), () {
        forceCheck();
      });
    }
  }

  /// Espera conexión estable
  Future<bool> waitForConnection([Duration timeout = const Duration(seconds: 3)]) async {
    await waitForInit();
    if (isOnline) return true;

    final completer = Completer<bool>();
    Timer? timer;
    StreamSubscription? sub;

    timer = Timer(timeout, () {
      sub?.cancel();
      if (!completer.isCompleted) completer.complete(false);
    });

    sub = _isOnline.listen((connected) {
      if (connected) {
        timer?.cancel();
        sub?.cancel();
        if (!completer.isCompleted) completer.complete(true);
      }
    });

    return completer.future;
  }

  /// Registra callback con prioridad
  void addCallback(bool onConnected, Future<void> Function() callback, {int priority = 0, String? id}) {
    final list = onConnected ? _onConnectedCallbacks : _onDisconnectedCallbacks;

    if (id != null) list.removeWhere((e) => e.id == id);
    list.add(CallbackEntry(priority, callback, id));
  }

  /// Remueve callback por ID
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