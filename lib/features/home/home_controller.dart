import 'package:get/get.dart';
import '../../app/data/models/attendance_model.dart';
import '../../app/data/services/storage_service.dart';
import '../../app/core/constants/storage_constants.dart';

class HomeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final RxList<AttendanceModel> attendances = <AttendanceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAttendances();
  }

  void loadAttendances() {
    final raw = _storageService.read<List>(StorageConstants.attendances);
    if (raw != null) {
      attendances.value = raw
          .map((e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
  }

  void refreshAttendances() {
    loadAttendances();
  }

  String get totalHadir =>
      attendances.where((a) => a.status == 'Hadir').length.toString();

  String get totalIzin =>
      attendances.where((a) => a.status == 'Izin').length.toString();

  String get totalSakit =>
      attendances.where((a) => a.status == 'Sakit').length.toString();
}
