import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/attendance_model.dart';
import '../../core/constants/storage_constants.dart';

class StorageService extends GetxService {
  // Inisialisasi langsung tanpa late untuk mencegah LateInitializationError
  final GetStorage _box = GetStorage();


  // ─── Generic Storage Methods ─────────────────────────────────────────────

  /// Read data by key
  T? read<T>(String key) => _box.read<T>(key);

  /// Write data to storage
  Future<void> write(String key, dynamic value) async =>
      await _box.write(key, value);

  /// Remove data by key
  Future<void> remove(String key) async => await _box.remove(key);

  /// Check if key exists
  bool hasData(String key) => _box.hasData(key);

  /// Clear all stored data
  Future<void> erase() async => await _box.erase();

  /// Listen to changes on a specific key — use in onInit() of controllers.
  /// Returns a VoidCallback disposer to call in onClose().
  void Function() listenKey(String key, void Function(dynamic) callback) =>
      _box.listenKey(key, callback);

  // ─── Attendance-Specific Methods ─────────────────────────────────────────

  /// Load all attendance records from storage (newest first)
  List<AttendanceModel> getAttendances() {
    final raw = _box.read<List>(StorageConstants.attendances);
    if (raw == null || raw.isEmpty) return [];
    return raw
        .map((e) =>
            AttendanceModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// Append a new attendance record to storage
  Future<void> saveAttendance(AttendanceModel model) async {
    final raw = _box.read<List>(StorageConstants.attendances) ?? [];
    final updated = [...raw, model.toJson()];
    await _box.write(StorageConstants.attendances, updated);
  }

  /// Delete an attendance record by ID
  Future<void> deleteAttendance(String id) async {
    final raw = _box.read<List>(StorageConstants.attendances) ?? [];
    final updated = raw.where((e) => (e as Map)['id'] != id).toList();
    await _box.write(StorageConstants.attendances, updated);
  }
}
