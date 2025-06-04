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

  Future<int?> incrementRevisitCount(String homeCode) async {
    final entry = _revisitBox.toMap().entries.firstWhereOrNull(
          (e) => e.value.homeCode == homeCode,
    );

    if (entry == null) return null;

    final int newCount = entry.value.revisitNumber + 1;

    if (newCount >= 3) {
      await removeRevisit(homeCode);
    } else {
      await _revisitBox.put(entry.key, entry.value.copyWith(
        revisitNumber: newCount,
      ));
    }

    return newCount;
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
}
