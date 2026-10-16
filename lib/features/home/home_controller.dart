import 'package:get/get.dart';
import '../../app/core/constants/app_strings.dart';
import '../../app/data/models/attendance_model.dart';
import '../../app/data/services/attendance_service.dart';
import '../../app/data/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class HomeController extends GetxController {
  final AttendanceService _attendanceService = Get.find<AttendanceService>();
  final AuthService _authService = Get.find<AuthService>();

  // ─── Reactive Attendance List ─────────────────────────────────────────────
  /// Direct reference to AttendanceService.attendances RxList.
  /// Obx widgets observing this list react immediately without manual reloads.
  RxList<AttendanceModel> get attendances => _attendanceService.attendances;

  // ─── Header & Greeting Getters ────────────────────────────────────────────
  /// Current authenticated user's name
  String get username =>
      _authService.username.isNotEmpty ? _authService.username : 'Pengguna';

  /// Dynamic time-based greeting in Indonesian
  String get dynamicGreeting {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  // ─── Summary Statistics ───────────────────────────────────────────────────
  /// Total Hadir count
  int get totalHadir => _attendanceService.totalHadir;

  /// Total Izin count
  int get totalIzin => _attendanceService.totalIzin;

  /// Total Sakit count
  int get totalSakit => _attendanceService.totalSakit;

  /// Total attendances recorded
  int get totalCount => _attendanceService.totalCount;

  // ─── Actions ──────────────────────────────────────────────────────────────
  /// Deletes an attendance record from RxList and GetStorage
  Future<void> deleteAttendance(String id) async {
    await _attendanceService.deleteAttendance(id);
  }

  /// Takes a photo for Hadir before opening the attendance form.
  Future<void> startAttendance(String status) async {
    String? photoPath;

    if (status == AppStrings.statusHadir) {
      final result = await Get.toNamed(AppRoutes.cameraCapture);
      if (isClosed || result is! String || result.trim().isEmpty) return;
      photoPath = result;
    }

    await Get.toNamed(
      AppRoutes.attendanceForm,
      arguments: <String, dynamic>{
        'status': status,
        'photoPath': photoPath,
        'openConfirmationImmediately': true,
      },
    );
  }

  /// Logs out the user, clears session storage, and routes to login
  Future<void> logout() async {
    await _authService.logout();
  }
}
