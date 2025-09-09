import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/storage_service.dart';

class ThemeController extends GetxController with WidgetsBindingObserver {
  static const String _themeKey = 'themeMode';
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  final StorageService _storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadThemeFromStorage();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangePlatformBrightness() {
    if (themeMode.value == ThemeMode.system) update();
  }

  bool get isDarkMode =>
      themeMode.value == ThemeMode.dark ||
          (themeMode.value == ThemeMode.system &&
              WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

  ThemeData get currentTheme =>
      AppTheme.build(isDarkMode ? Brightness.dark : Brightness.light);

  void toggleTheme(ThemeMode mode) {
    themeMode.value = mode;
    _storage.set<String>(_themeKey, mode.name);
    update();
  }

  void _loadThemeFromStorage() {
    final saved = _storage.get<String>(_themeKey, defaultValue: 'system');
    themeMode.value = ThemeMode.values.firstWhere(
          (e) => e.name == saved,
      orElse: () => ThemeMode.system,
    );
    update();
  }
}
