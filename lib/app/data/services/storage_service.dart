import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  @override
  void onInit() {
    super.onInit();
    _box = GetStorage();
  }

  /// Read data by key
  T? read<T>(String key) {
    return _box.read<T>(key);
  }

  /// Write data to storage
  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  /// Remove data by key
  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  /// Check if key exists
  bool hasData(String key) {
    return _box.hasData(key);
  }

  /// Clear all stored data
  Future<void> erase() async {
    await _box.erase();
  }
}
