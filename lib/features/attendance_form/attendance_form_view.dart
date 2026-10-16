import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/core/constants/app_strings.dart';
import '../../app/core/theme/app_colors.dart';
import 'attendance_form_controller.dart';

class AttendanceFormView extends GetView<AttendanceFormController> {
  const AttendanceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.openConfirmationImmediately) {
      return const Scaffold(backgroundColor: Colors.white);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Catat Presensi Real-Time',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Anti-Cheat Real-Time Timestamp Banner (Biru Solid + Aksen Kuning)
              _buildRealTimeTimestampBanner(),
              const SizedBox(height: 24),

              // 2. Status Kehadiran Section
              _buildSectionHeader(
                icon: Icons.verified_user_rounded,
                title: 'Status Kehadiran',
                subtitle: 'Pilih salah satu status yang sesuai',
              ),
              const SizedBox(height: 12),
              _buildChoiceChips(),
              const SizedBox(height: 20),

              // 3. Khusus Hadir: Prototype Camera Verification Card
              Obx(() {
                if (controller.selectedStatus.value != AppStrings.statusHadir) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    _buildCameraVerificationCard(),
                    const SizedBox(height: 20),
                  ],
                );
              }),

              // 4. Catatan / Keterangan Section
              _buildSectionHeader(
                icon: Icons.edit_note_rounded,
                title: 'Catatan / Keterangan',
                subtitle: 'Keterangan tambahan untuk presensi',
              ),
              const SizedBox(height: 12),
              _buildNoteInput(),
              const SizedBox(height: 32),

              // 5. Tombol Simpan Presensi (Kombinasi Biru & Kuning)
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Real-Time Timestamp Info Banner (Biru Solid + Border Kuning) ─────────
  Widget _buildRealTimeTimestampBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_clock_rounded,
                      color: AppColors.textPrimary,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'SISTEM ANTI-CHEAT REAL-TIME',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() {
            final now = controller.currentSystemTime.value;
            final dayFormatted = DateFormat('EEEE', 'id_ID').format(now);
            final dateFormatted = DateFormat(
              'd MMMM yyyy',
              'id_ID',
            ).format(now);
            final timeFormatted = DateFormat('HH:mm:ss').format(now);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dayFormatted, $dateFormatted',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      timeFormatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'WIB',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.accent,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Waktu presensi dicatat otomatis berdasarkan waktu sistem saat ini untuk mencegah manipulasi data kehadiran.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Camera Verification Card (Khusus Hadir) ──────────────────────────────
  Widget _buildCameraVerificationCard() {
    return Obx(() {
      final isVerified = controller.isPhotoVerified.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isVerified ? AppColors.primaryLight : AppColors.accentLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isVerified ? AppColors.hadir : AppColors.accent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isVerified ? AppColors.hadir : AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVerified
                    ? Icons.check_circle_rounded
                    : Icons.camera_alt_rounded,
                color: isVerified ? Colors.white : AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVerified ? 'Foto Presensi Siap' : 'Foto Presensi Wajib',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isVerified
                          ? AppColors.primaryDark
                          : const Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isVerified
                        ? 'Foto kehadiran Anda siap dikirim bersama presensi'
                        : 'Ambil foto wajah Anda sebelum menyimpan presensi',
                    style: TextStyle(
                      fontSize: 12,
                      color: isVerified
                          ? AppColors.primary
                          : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: controller.openCameraVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: isVerified ? Colors.white : AppColors.primary,
                foregroundColor: isVerified ? AppColors.primary : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                side: isVerified
                    ? const BorderSide(color: AppColors.primary)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isVerified ? 'Ulang' : 'Buka Kamera',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── Section Header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Interactive ChoiceChips (Tanpa Gradasi) ───────────────────────────────
  Widget _buildChoiceChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.statusOptions.map((status) {
                final isSelected = controller.selectedStatus.value == status;
                final statusColor = _statusColor(status);
                final statusIcon = _statusIcon(status);

                return ChoiceChip(
                  avatar: Icon(
                    isSelected ? Icons.check_circle_rounded : statusIcon,
                    color: isSelected ? Colors.white : statusColor,
                    size: 18,
                  ),
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectStatus(status);
                    }
                  },
                  selectedColor: statusColor,
                  backgroundColor: statusColor.withValues(alpha: 0.08),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 14,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: isSelected ? statusColor : AppColors.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  elevation: isSelected ? 2 : 0,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final isHadir =
                controller.selectedStatus.value == AppStrings.statusHadir;
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isHadir
                    ? AppColors.hadir.withValues(alpha: 0.08)
                    : AppColors.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isHadir
                        ? Icons.camera_alt_outlined
                        : Icons.warning_amber_rounded,
                    size: 16,
                    color: isHadir ? AppColors.hadir : AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isHadir
                          ? 'Status Hadir: Wajib verifikasi foto wajah melalui kamera.'
                          : 'Status ${controller.selectedStatus.value}: Wajib mengisi catatan alasan.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isHadir
                            ? AppColors.primary
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Multi-line Note Field with Visual Counter ────────────────────────────
  Widget _buildNoteInput() {
    return Obx(() {
      final required = controller.isNoteRequired;
      final status = controller.selectedStatus.value;

      String hint;
      if (status == AppStrings.statusHadir) {
        hint = 'Tambahkan catatan opsional jika diperlukan...';
      } else if (status == AppStrings.statusIzin) {
        hint =
            'Wajib: Jelaskan alasan permohonan izin (misal: Keperluan keluarga)...';
      } else {
        hint = 'Wajib: Tuliskan keterangan sakit atau informasi istirahat...';
      }

      return TextFormField(
        controller: controller.noteController,
        maxLines: 4,
        minLines: 3,
        maxLength: 200,
        validator: controller.validateNote,
        decoration: InputDecoration(
          labelText: required
              ? 'Catatan Presensi (Wajib) *'
              : 'Catatan Presensi (Opsional)',
          labelStyle: TextStyle(
            color: required ? AppColors.sakit : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          hintText: hint,
          alignLabelWithHint: true,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: Icon(Icons.notes_rounded, color: AppColors.primary),
          ),
          counterStyle: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }

  // ─── Tombol Simpan (Biru Solid + Ikon Kuning, Tanpa Gradasi) ──────────────
  Widget _buildSubmitButton() {
    return Obx(() {
      final loading = controller.isLoading.value;

      return Container(
        height: 52,
        decoration: BoxDecoration(
          color: loading ? Colors.grey.shade400 : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: loading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: loading ? null : controller.processAttendance,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          color: AppColors.accent,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Lanjutkan Konfirmasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Color & Icon Helpers ─────────────────────────────────────────────────
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
