import 'package:get/get.dart';
import 'package:hive/hive.dart';

class TextScaleController extends GetxController {
  final Rx<AppTextScale> textScale = AppTextScale.normal.obs;

  static const _key = 'textScale';

  @override
  void onInit() {
    super.onInit();
    final box = Hive.box('settings');
    final saved = box.get(_key, defaultValue: 'normal');
    textScale.value = AppTextScale.values.firstWhere(
          (e) => e.name == saved,
      orElse: () => AppTextScale.normal,
    );
  }

  void updateScale(AppTextScale newScale) {
    textScale.value = newScale;
    Hive.box('settings').put(_key, newScale.name);
    update();
  }

  double get factor => textScale.value.factor;
}


enum AppTextScale {
  normal,
  small,
  large,
}

extension AppTextScaleExtension on AppTextScale {
  double get factor {
    switch (this) {
      case AppTextScale.small:
        return 0.85;
      case AppTextScale.normal:
        return 1.0;
      case AppTextScale.large:
        return 1.15;
    }
  }
}
