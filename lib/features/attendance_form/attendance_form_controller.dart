import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/core/constants/app_strings.dart';
import '../../app/core/theme/app_colors.dart';
import '../../app/data/models/attendance_model.dart';
import '../../app/data/services/attendance_service.dart';
import '../../app/routes/app_routes.dart';

class AttendanceFormController extends GetxController {
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  // ─── Form Key & Controllers ───────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final confirmationFormKey = GlobalKey<FormState>();
  final noteController = TextEditingController();
  final lateArrivalNoteController = TextEditingController();
  final Rx<Future<Uint8List>?> photoBytes = Rx<Future<Uint8List>?>(null);

  // ─── Reactive State ───────────────────────────────────────────────────────
  /// Status kehadiran yang dipilih — default 'Hadir'
  final RxString selectedStatus = AppStrings.statusHadir.obs;

  /// Status verifikasi foto kamera khusus status 'Hadir'
  final RxBool isPhotoVerified = false.obs;

  /// Path foto hasil verifikasi kamera
  final RxString photoPath = ''.obs;

  /// Waktu sistem real-time aktif (diperbarui otomatis setiap detik, anti-manipulasi)
  final Rx<DateTime> currentSystemTime = DateTime.now().obs;

  /// Indikator loading saat proses penyimpanan berlangsung
  final RxBool isLoading = false.obs;
  bool openConfirmationImmediately = false;
  bool _confirmationOpened = false;

  /// Timer untuk live clock
  Timer? _clockTimer;

  // ─── Pilihan Status Dinamis ───────────────────────────────────────────────
  final List<String> statusOptions = const [
    AppStrings.statusHadir,
    AppStrings.statusIzin,
    AppStrings.statusSakit,
  ];

  // ─── Properti Logika Validasi ─────────────────────────────────────────────
  /// Catatan wajib diisi jika status 'Izin' atau 'Sakit', opsional jika 'Hadir'
  bool get isNoteRequired =>
      selectedStatus.value == AppStrings.statusIzin ||
      selectedStatus.value == AppStrings.statusSakit;

  bool get isLateArrivalRequired =>
      selectedStatus.value == AppStrings.statusHadir &&
      currentSystemTime.value.hour >= 9;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      openConfirmationImmediately =
          arguments['openConfirmationImmediately'] == true;

      final status = arguments['status'];
      if (status is String && statusOptions.contains(status)) {
        selectedStatus.value = status;
      }

      final initialPhotoPath = arguments['photoPath'];
      if (selectedStatus.value == AppStrings.statusHadir &&
          initialPhotoPath is String &&
          initialPhotoPath.trim().isNotEmpty) {
        photoPath.value = initialPhotoPath;
        isPhotoVerified.value = true;
        photoBytes.value = XFile(initialPhotoPath).readAsBytes();
      }
    }

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      currentSystemTime.value = DateTime.now();
    });
  }

  @override
  void onReady() {
    super.onReady();
    if (openConfirmationImmediately) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) showConfirmationModal();
      });
    }
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    noteController.dispose();
    lateArrivalNoteController.dispose();
    super.onClose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────
  /// Memilih status kehadiran
  void selectStatus(String status) {
    selectedStatus.value = status;
    // A photo belongs only to a "Hadir" submission.  Do not accidentally
    // carry a previous camera result into an Izin/Sakit record.
    if (status != AppStrings.statusHadir) {
      isPhotoVerified.value = false;
      photoPath.value = '';
    }
    formKey.currentState?.validate();
  }

  /// Membuka kamera untuk verifikasi foto wajah (khusus Hadir)
  Future<void> openCameraVerification() async {
    final result = await Get.toNamed(AppRoutes.cameraCapture);
    if (isClosed) return;

    if (result is String && result.isNotEmpty) {
      photoPath.value = result;
      isPhotoVerified.value = true;
      photoBytes.value = XFile(result).readAsBytes();
    } else {
      photoPath.value = '';
      isPhotoVerified.value = false;
      photoBytes.value = null;
    }
  }

  /// Validasi catatan utama (max 200 karakter, wajib jika Izin/Sakit)
  String? validateNote(String? value) {
    final text = value?.trim() ?? '';
    if (isNoteRequired && text.isEmpty) {
      return 'Keterangan wajib diisi untuk status "${selectedStatus.value}"';
    }
    if (text.length > 200) {
      return 'Keterangan maksimal 200 karakter (saat ini ${text.length} karakter)';
    }
    return null;
  }

  String? validateLateArrivalNote(String? value) {
    final text = value?.trim() ?? '';
    if (isLateArrivalRequired && text.isEmpty) {
      return 'Alasan keterlambatan wajib diisi setelah pukul 09.00.';
    }
    if (text.length > 200) {
      return 'Keterangan maksimal 200 karakter.';
    }
    return null;
  }

  /// Alur Utama Presensi:
  /// a. Validasi form input awal.
  /// b. Jika status "Hadir", buka kamera jika belum diverifikasi. Jika "Izin"/"Sakit", lewati.
  /// c. Setelah foto berhasil diambil (atau langsung jika Izin/Sakit), JANGAN LANGSUNG SIMPAN,
  ///    melainkan tampilkan Modal / BottomSheet Konfirmasi (showConfirmationModal).
  Future<void> processAttendance() async {
    // a. Validasi form awal
    if (!(formKey.currentState?.validate() ?? false)) return;

    final isPresent = selectedStatus.value == AppStrings.statusHadir;

    // b. Izin dan Sakit never use a camera result.  Clear it here as a
    // second safeguard in addition to selectStatus(), then continue directly
    // to confirmation.
    if (!isPresent) {
      isPhotoVerified.value = false;
      photoPath.value = '';
      showConfirmationModal();
      return;
    }

    // Khusus status Hadir, verifikasi kamera wajib.
    if (!isPhotoVerified.value) {
      Get.snackbar(
        'Foto Presensi Wajib 📷',
        'Silakan ambil foto sebelum melanjutkan konfirmasi presensi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(
          Icons.camera_alt_rounded,
          color: AppColors.accent,
          size: 28,
        ),
      );

      await openCameraVerification();

      // Jika setelah membuka kamera pengguna belum memotret/membatalkan, jangan buka modal
      if (!isPhotoVerified.value) return;
    }

    // c. Tampilkan Modal/BottomSheet Konfirmasi
    showConfirmationModal();
  }

  /// Menampilkan BottomSheet Modal Konfirmasi Interaktif
  void showConfirmationModal() {
    if (_confirmationOpened &&
        openConfirmationImmediately &&
        Get.isBottomSheetOpen == true) {
      return;
    }
    _confirmationOpened = true;
    // Reset input alasan telat setiap kali modal dibuka
    lateArrivalNoteController.clear();

    Get.bottomSheet(
      _buildConfirmationBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: !openConfirmationImmediately,
      isDismissible: !openConfirmationImmediately,
    );
  }

  void cancelConfirmation() {
    if (openConfirmationImmediately) {
      Get.back();
      Get.back();
      return;
    }
    Get.back();
  }

  /// Widget konten BottomSheet Modal Konfirmasi
  Widget _buildConfirmationBottomSheet() {
    final status = selectedStatus.value;
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull Handle Bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Modal Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fact_check_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konfirmasi Presensi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pastikan data kehadiran Anda sudah sesuai',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge Status
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
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Real-Time System Timestamp Card
              Obx(() {
                final now = currentSystemTime.value;
                final dayFormatted = DateFormat(
                  'EEEE, d MMMM yyyy',
                  'id_ID',
                ).format(now);
                final timeFormatted = DateFormat('HH:mm:ss').format(now);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayFormatted,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  timeFormatted,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'WIB',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Text(
                          'ANTI-CHEAT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              if (photoPath.value.isNotEmpty) ...[
                _AttendancePhotoPreview(photoBytes: photoBytes.value),
                const SizedBox(height: 16),
              ],

              Form(
                key: confirmationFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Catatan / Keterangan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: noteController,
                      maxLines: 3,
                      minLines: 2,
                      maxLength: 200,
                      validator: validateNote,
                      decoration: const InputDecoration(
                        hintText:
                            'Tuliskan catatan atau keterangan presensi...',
                        prefixIcon: Icon(
                          Icons.notes_rounded,
                          color: AppColors.primary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => Text(
                        isLateArrivalRequired
                            ? 'Alasan Keterlambatan (Wajib) *'
                            : 'Alasan Telat / Keterangan Tambahan (Opsional)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: lateArrivalNoteController,
                      maxLines: 2,
                      minLines: 1,
                      maxLength: 200,
                      validator: validateLateArrivalNote,
                      decoration: const InputDecoration(
                        hintText:
                            'Tuliskan alasan keterlambatan atau catatan tambahan...',
                        prefixIcon: Icon(
                          Icons.add_comment_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        counterStyle: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Konfirmasi & Kirim Presensi (Biru Solid)
              Obx(() {
                final loading = isLoading.value;

                return Column(
                  children: [
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: loading
                            ? Colors.grey.shade400
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: loading
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: loading ? null : confirmAndSaveAttendance,
                          child: Center(
                            child: loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.accent,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Konfirmasi & Kirim Presensi',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: loading ? null : cancelConfirmation,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        'Kembali & Periksa Ulang',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Menyimpan presensi permanen setelah dikonfirmasi di modal:
  /// - Menggabungkan catatan utama & alasan telat
  /// - Mengambil waktu real-time mutlak saat konfirmasi
  /// - Menyimpan ke AttendanceService
  /// - Menutup modal & kembali ke Home dengan snackbar sukses
  Future<void> confirmAndSaveAttendance() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      // Record the immutable system timestamp only at confirmation time.  The
      // ISO value is what is persisted by AttendanceModel, not user input.
      final realTimeNow = DateTime.now();
      currentSystemTime.value = realTimeNow;
      if (!(confirmationFormKey.currentState?.validate() ?? false)) return;

      // Gabungkan catatan utama dan alasan telat
      final primaryNote = noteController.text.trim();
      final lateNote = lateArrivalNoteController.text.trim();
      if (lateNote.length > 200) {
        throw ArgumentError('Keterangan tambahan maksimal 200 karakter.');
      }
      String combinedNote = '';

      if (primaryNote.isNotEmpty && lateNote.isNotEmpty) {
        combinedNote = '$primaryNote (Ket. Tambahan / Telat: $lateNote)';
      } else if (primaryNote.isNotEmpty) {
        combinedNote = primaryNote;
      } else if (lateNote.isNotEmpty) {
        combinedNote = 'Ket. Tambahan / Telat: $lateNote';
      }

      final newAttendance = AttendanceModel(
        id: realTimeNow.millisecondsSinceEpoch.toString(),
        dateTime: realTimeNow,
        status: selectedStatus.value,
        note: combinedNote,
        photoPath:
            selectedStatus.value == AppStrings.statusHadir &&
                isPhotoVerified.value &&
                photoPath.value.isNotEmpty
            ? photoPath.value
            : null,
      );

      // Simpan langsung dan kunci ke AttendanceService
      await _attendanceService.addAttendance(newAttendance);

      // Tutup BottomSheet Modal jika terbuka
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      // Kembali ke halaman Home
      Get.back();

      // Tampilkan notifikasi keberhasilan
      Get.snackbar(
        'Presensi Berhasil Terverifikasi ✅',
        'Presensi "${newAttendance.status}" telah tersimpan pada waktu sistem real-time.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.hadir,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.verified_rounded, color: Colors.white, size: 28),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Menyimpan Presensi',
        'Terjadi kendala pada sistem. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.sakit,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
        duration: const Duration(seconds: 3),
        icon: const Icon(
          Icons.error_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppStrings.statusHadir:
        return AppColors.hadir;
      case AppStrings.statusIzin:
        return AppColors.izin;
      case AppStrings.statusSakit:
        return AppColors.sakit;
      default:
        return AppColors.primary;
    }
  }
}

class _AttendancePhotoPreview extends StatelessWidget {
  const _AttendancePhotoPreview({required this.photoBytes});

  final Future<Uint8List>? photoBytes;

  @override
  Widget build(BuildContext context) {
    final bytes = photoBytes;
    if (bytes == null) {
      return const Text(
        'Foto bukti tidak dapat ditampilkan.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      );
    }

    return FutureBuilder<Uint8List>(
      future: bytes,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Foto bukti tidak dapat ditampilkan.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 96,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            snapshot.data!,
            height: 144,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
