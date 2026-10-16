import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/storage_constants.dart';
import '../models/attendance_model.dart';

class AttendanceSummary {
  final int hadir;
  final int izin;
  final int sakit;
  final int total;

  const AttendanceSummary({
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.total,
  });
}

class AttendanceService extends GetxService {
  final RxList<AttendanceModel> attendances = <AttendanceModel>[].obs;

  // Inisialisasi langsung sekali tanpa keyword late untuk mencegah LateInitializationError
  final GetStorage _box = GetStorage();

  /// Inisialisasi asinkron untuk registrasi Get.putAsync()
  Future<AttendanceService> init() async {
    loadFromStorage();
    return this;
  }

  /// Memuat daftar presensi dari GetStorage secara aman
  void loadFromStorage() {
    final parsed = <AttendanceModel>[];

    try {
      final raw = _box.read<dynamic>(StorageConstants.attendances);
      if (raw is List) {
        for (final item in raw) {
          try {
            if (item is! Map) continue;
            parsed.add(
              AttendanceModel.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (error, stackTrace) {
            // Skip only the malformed item; valid attendance history remains.
            debugPrint('Ignoring corrupt attendance item: $error\n$stackTrace');
          }
        }
      } else if (raw != null) {
        debugPrint('Ignoring corrupt attendance storage payload.');
      }
    } catch (error, stackTrace) {
      // A corrupt local payload must never prevent the app from starting.
      debugPrint('Unable to read attendance storage: $error\n$stackTrace');
    }

    parsed.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    attendances.assignAll(parsed);
  }

  /// Tambah presensi baru ke RxList dan simpan permanen ke GetStorage
  Future<void> addAttendance(AttendanceModel model) async {
    attendances.insert(0, model);
    attendances.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await _persist();
  }

  /// Hapus presensi berdasarkan ID dan update GetStorage
  Future<void> deleteAttendance(String id) async {
    attendances.removeWhere((item) => item.id == id);
    await _persist();
  }

  /// Simpan state RxList ke GetStorage
  Future<void> _persist() async {
    final rawList = attendances.map((item) => item.toJson()).toList();
    await _box.write(StorageConstants.attendances, rawList);
  }

  /// Helper getter untuk statistik total presensi (Hadir, Izin, Sakit)
  AttendanceSummary get getAttendanceSummary {
    int hadir = 0;
    int izin = 0;
    int sakit = 0;

    for (final item in attendances) {
      switch (item.status) {
        case 'Hadir':
          hadir++;
          break;
        case 'Izin':
          izin++;
          break;
        case 'Sakit':
          sakit++;
          break;
      }
    }

    return AttendanceSummary(
      hadir: hadir,
      izin: izin,
      sakit: sakit,
      total: attendances.length,
    );
  }

  // Convenience getters
  int get totalHadir => attendances.where((a) => a.status == 'Hadir').length;
  int get totalIzin => attendances.where((a) => a.status == 'Izin').length;
  int get totalSakit => attendances.where((a) => a.status == 'Sakit').length;
  int get totalCount => attendances.length;
}
