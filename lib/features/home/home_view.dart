import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/core/constants/app_strings.dart';
import '../../app/core/theme/app_colors.dart';
import '../../app/data/models/attendance_model.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Header & Summary Cards pinned at top
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildSummarySection(),
                  const SizedBox(height: 20),
                  _buildHistoryHeader(),
                ],
              ),
            ),
            // Reactive ListView observing AttendanceService.attendances
            Expanded(
              child: Obx(() {
                if (controller.attendances.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 250));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: controller.attendances.length,
                    itemBuilder: (context, index) {
                      final item = controller.attendances[index];
                      return _buildAttendanceCard(item);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        AppStrings.appName,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: -0.3,
          color: AppColors.textPrimary,
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      actions: [
        IconButton(
          tooltip: 'Keluar',
          icon: const Icon(Icons.logout_rounded, color: AppColors.sakit),
          onPressed: _showLogoutConfirmation,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─── Header Section (Biru Solid Tegas + Aksen Kuning, Tanpa Gradasi) ───────
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.dynamicGreeting} 👋',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _showLogoutConfirmation,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.accent,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat(
                    'EEEE, d MMMM yyyy',
                    'id_ID',
                  ).format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dashboard Summary Cards (Putih Bersih, Statistik Real-Time) ───────────
  Widget _buildSummarySection() {
    return Obx(() {
      return Row(
        children: [
          _buildSummaryBadge(
            label: 'Hadir',
            count: controller.totalHadir,
            color: AppColors.hadir,
            icon: Icons.check_circle_rounded,
          ),
          const SizedBox(width: 10),
          _buildSummaryBadge(
            label: 'Izin',
            count: controller.totalIzin,
            color: AppColors.izin,
            icon: Icons.event_note_rounded,
          ),
          const SizedBox(width: 10),
          _buildSummaryBadge(
            label: 'Sakit',
            count: controller.totalSakit,
            color: AppColors.sakit,
            icon: Icons.medical_services_rounded,
          ),
        ],
      );
    });
  }

  Widget _buildSummaryBadge({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── History Header ───────────────────────────────────────────────────────
  Widget _buildHistoryHeader() {
    return Obx(() {
      final count = controller.attendances.length;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.attendanceHistory,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              '$count Data',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      );
    });
  }

  // ─── Attendance Item Card (Putih Bersih + Kontras Tinggi) ─────────────────
  Widget _buildAttendanceCard(AttendanceModel item) {
    final statusColor = _statusColor(item.status);
    final statusIcon = _statusIcon(item.status);

    final formattedDateTime = DateFormat(
      'EEEE, d MMMM yyyy • HH:mm',
      'id_ID',
    ).format(item.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Status
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                // Formatted Date & Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDateTime,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Dynamic Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Tombol Hapus dengan Dialog Konfirmasi
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  tooltip: 'Hapus Data',
                  onPressed: () => _showDeleteConfirmation(item),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            const SizedBox(height: 10),
            // Teks Catatan
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: item.note.isNotEmpty
                      ? Text(
                          item.note,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        )
                      : Text(
                          'Tanpa catatan',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            if (item.photoPath != null && item.photoPath!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.hadir.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.hadir.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 14,
                      color: AppColors.hadir,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Verifikasi Kamera Lolos',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Empty State UI ───────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Riwayat Presensi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Presensi Anda belum tercatat hari ini. Tekan tombol "+ Catat Presensi" di bawah untuk mencatat kehadiran.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Floating Action Button (Biru Solid + Aksen Kuning, Tanpa Gradasi) ────
  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _showAttendanceStatusPicker,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppColors.accent, size: 22),
                SizedBox(width: 8),
                Text(
                  '+ Catat Presensi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAttendanceStatusPicker() async {
    final status = await Get.bottomSheet<String>(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Text(
                'Pilih Status Presensi',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Untuk status Hadir, ambil foto sebelum konfirmasi presensi.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              for (final status in const [
                AppStrings.statusHadir,
                AppStrings.statusIzin,
                AppStrings.statusSakit,
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: status),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (status != null) {
      await controller.startAttendance(status);
    }
  }

  // ─── Dialogs & Actions ────────────────────────────────────────────────────
  void _showDeleteConfirmation(AttendanceModel item) {
    Get.defaultDialog(
      title: 'Hapus Presensi',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 17,
        color: AppColors.textPrimary,
      ),
      middleText:
          'Yakin ingin menghapus presensi "${item.status}" pada ${DateFormat("d MMM yyyy, HH:mm", "id_ID").format(item.dateTime)}?',
      middleTextStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.sakit,
      cancelTextColor: AppColors.textPrimary,
      radius: 14,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      onConfirm: () async {
        Get.back();
        await controller.deleteAttendance(item.id);
        Get.snackbar(
          'Presensi Dihapus',
          'Catatan presensi telah berhasil dihapus.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.textPrimary,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    Get.defaultDialog(
      title: 'Konfirmasi Keluar',
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 17,
        color: AppColors.textPrimary,
      ),
      middleText: 'Apakah Anda yakin ingin keluar dari akun Anda?',
      middleTextStyle: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
      textConfirm: 'Keluar',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.sakit,
      cancelTextColor: AppColors.textPrimary,
      radius: 14,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      onConfirm: () {
        Get.back();
        controller.logout();
      },
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
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
        return Icons.check_circle_rounded;
      case AppStrings.statusIzin:
        return Icons.event_note_rounded;
      case AppStrings.statusSakit:
        return Icons.medical_services_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
