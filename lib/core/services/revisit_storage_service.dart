import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

import '../../app/data/models/revisit_model.dart';

class RevisitStorageService extends GetxService {
  final Box<RevisitModel> _revisitBox = Hive.box<RevisitModel>('revisitsBox');

  /// Guarda una revisita y devuelve el índice asignado
  Future<int> addRevisit(RevisitModel revisit) async {
    return await _revisitBox.add(revisit);
  }

  /// Obtiene todas las revisitas almacenadas
  List<RevisitModel> getAllRevisits() {
    return _revisitBox.values.toList();
  }

  Future<RevisitModel?> incrementRevisitCount(String homeCode, {required String newReason}) async {
    final entry = _revisitBox.toMap().entries.firstWhereOrNull(
          (e) => e.value.homeCode == homeCode,
    );

    print(entry);

    if (entry == null) return null;

    final current = entry.value;
    final int newCount = current.revisitNumber + 1;

    RevisitModel? updated;

    if (newCount >= 3) {
      // Elimina la revisita si se excede el límite
      await removeRevisit(homeCode);
      updated = null;
    } else {
      updated = current.copyWith(
        revisitNumber: newCount,
        reason: '${current.reason}; $newReason',
        date: DateTime.now(),
      );
      await _revisitBox.put(entry.key, updated);
    }

    return updated;
  }

  /// Elimina una revisita por su índice
  Future<void> removeRevisit(String homeCode) async {
    final entry = _revisitBox.toMap().entries.firstWhereOrNull(
          (e) => e.value.homeCode == homeCode,
    );

    if (entry != null) {
      await _revisitBox.delete(entry.key);
    }
  }

  Future<RevisitModel?> getRevisitByHomeCode(String homeCode) async {
    return _revisitBox.values.firstWhereOrNull((revisit) => revisit.homeCode == homeCode);
  }


}
