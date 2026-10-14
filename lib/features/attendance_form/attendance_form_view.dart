import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/core/constants/app_strings.dart';
import '../../app/core/theme/app_colors.dart';
import '../../app/core/utils/validators.dart';
import 'attendance_form_controller.dart';

class AttendanceFormView extends GetView<AttendanceFormController> {
  const AttendanceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.attendanceRecord),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateCard(),
              const SizedBox(height: 20),
              _buildStatusPicker(),
              const SizedBox(height: 20),
              _buildNoteField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE', 'id_ID').format(now),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                DateFormat('d MMMM yyyy', 'id_ID').format(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                DateFormat('HH:mm').format(now),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Kehadiran',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: controller.statusOptions.map((status) {
                final isSelected = controller.selectedStatus.value == status;
                final statusColor = _statusColor(status);
                final statusIcon = _statusIcon(status);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectStatus(status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right:
                            status != controller.statusOptions.last ? 10 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? statusColor.withValues(alpha: 0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? statusColor : AppColors.border,
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(statusIcon,
                              color: isSelected
                                  ? statusColor
                                  : AppColors.textSecondary,
                              size: 24),
                          const SizedBox(height: 8),
                          Text(
                            status,
                            style: TextStyle(
                              color: isSelected
                                  ? statusColor
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keterangan (Opsional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.noteController,
          maxLines: 3,
          maxLength: 250,
          validator: Validators.note,
          decoration: const InputDecoration(
            hintText: 'Tambahkan keterangan (misal: terlambat 15 menit)...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: controller.isLoading.value
                  ? [Colors.grey.shade300, Colors.grey.shade400]
                  : [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: controller.isLoading.value
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: controller.isLoading.value ? null : controller.submitForm,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Kehadiran',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ));
  }

  Color _statusColor(String status) {
    switch (status) {
      case AppStrings.statusHadir:
        return AppColors.hadir;
      case AppStrings.statusIzin:
        return AppColors.izin;
      case AppStrings.statusSakit:
        return AppColors.sakit;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case AppStrings.statusHadir:
        return Icons.check_circle_outline_rounded;
      case AppStrings.statusIzin:
        return Icons.event_note_rounded;
      case AppStrings.statusSakit:
        return Icons.medical_services_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
