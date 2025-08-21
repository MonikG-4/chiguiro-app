import 'package:get/get.dart';
import '../../../../../core/services/revisit_storage_service.dart';
import '../../data/models/revisit_model.dart';

class RevisitsController extends GetxController {
  final RevisitStorageService _revisitStorageService = Get.find();

  final revisits = <RevisitModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRevisits();
  }

  void loadRevisits() {
    revisits.value = _revisitStorageService.getAllRevisits()
      ..sort((a, b) => b.date.compareTo(a.date)); // más recientes arriba
  }
}
