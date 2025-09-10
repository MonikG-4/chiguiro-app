import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  final Box _box = Hive.box('settings');

  StorageService();

  T get<T>(String key, {T? defaultValue}) {
    return _box.get(key, defaultValue: defaultValue) as T;
  }

  Future<void> set<T>(String key, T value) async {
    await _box.put(key, value);
  }

  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  Future<void> clearExcept(String keyToKeep) async {
    final keysToDelete = _box.keys.where((key) => key != keyToKeep).toList();
    await _box.deleteAll(keysToDelete);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  bool containsKey(String key) {
    return _box.containsKey(key);
  }

  ValueListenable<Box> listenable({List<String>? keys}) {
    return _box.listenable(keys: keys);
  }
}
