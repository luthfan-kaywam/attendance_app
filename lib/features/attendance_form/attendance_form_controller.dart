import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/core/constants/app_strings.dart';
import '../../app/core/constants/storage_constants.dart';
import '../../app/core/theme/app_colors.dart';
import '../../app/data/models/attendance_model.dart';
import '../../app/data/services/storage_service.dart';

class AttendanceFormController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final formKey = GlobalKey<FormState>();
  final noteController = TextEditingController();

  final RxString selectedStatus = AppStrings.statusHadir.obs;
  final RxBool isLoading = false.obs;

  final List<String> statusOptions = [
    AppStrings.statusHadir,
    AppStrings.statusIzin,
    AppStrings.statusSakit,
  ];

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }

  void selectStatus(String status) {
    selectedStatus.value = status;
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 400));

      final newRecord = AttendanceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: DateTime.now(),
        status: selectedStatus.value,
        note: noteController.text.trim(),
      );

      final existing =
          _storageService.read<List>(StorageConstants.attendances) ?? [];
      final updated = [...existing, newRecord.toJson()];
      await _storageService.write(StorageConstants.attendances, updated);

      Get.back(result: true);
      Get.snackbar(
        'Berhasil',
        'Kehadiran berhasil dicatat!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.hadir,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
