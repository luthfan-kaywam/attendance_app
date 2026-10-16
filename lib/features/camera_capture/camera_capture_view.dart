import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/core/theme/app_colors.dart';
import 'camera_capture_controller.dart';

class CameraCaptureView extends GetView<CameraCaptureController> {
  const CameraCaptureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ambil Foto Presensi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'Ganti Kamera',
              icon: const Icon(
                Icons.flip_camera_ios_rounded,
                color: AppColors.accent,
              ),
              onPressed:
                  controller.cameras.length > 1 ||
                      !controller.isCameraAvailable.value
                  ? controller.toggleCamera
                  : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (!controller.isInitialized.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.accent,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Menghubungkan ke Sensor Kamera...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Kamera Asli (CameraPreview) atau Tampilan Sensor Prototype
              _buildCameraFeed(context),

              // 2. Overlay Bingkai Panduan Oval Berwarna Kuning
              const _OvalGuideOverlay(),

              // 3. Banner Petunjuk di Bagian Atas
              Positioned(
                top: 16,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accent, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.face_retouching_natural_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.isCameraAvailable.value
                              ? 'Posisikan wajah Anda tepat di dalam bingkai oval kuning'
                              : 'Kamera tidak tersedia. Periksa izin dan perangkat kamera.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol shutter langsung mengambil foto tanpa animasi verifikasi.
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Foto diperlukan untuk status Hadir',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Tombol Ambil Foto Berwarna Biru Solid
                    GestureDetector(
                      onTap: _captureAndReturn,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          border: Border.all(color: AppColors.accent, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.isCameraAvailable.value
                          ? 'Ketuk untuk Mengambil Foto'
                          : 'Kamera tidak tersedia',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _captureAndReturn() async {
    final camera = controller.cameraController;
    if (!controller.isCameraAvailable.value ||
        camera == null ||
        !camera.value.isInitialized ||
        camera.value.isTakingPicture) {
      Get.snackbar(
        'Kamera tidak tersedia',
        'Periksa izin kamera dan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final XFile picture = await camera.takePicture();
      Get.back(result: picture.path);
    } on CameraException catch (error) {
      Get.snackbar(
        'Gagal mengambil foto',
        error.description ?? error.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Tampilan Live CameraFeed jika hardware tersedia, atau fallback visual prototype
  Widget _buildCameraFeed(BuildContext context) {
    if (controller.isCameraAvailable.value &&
        controller.cameraController != null &&
        controller.cameraController!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.cameraController!.value.previewSize?.height ?? 1,
            height: controller.cameraController!.value.previewSize?.width ?? 1,
            child: CameraPreview(controller.cameraController!),
          ),
        ),
      );
    }

    // Keep a clear unavailable state instead of producing a fake photo.
    return Container(
      color: const Color(0xFF1E293B), // Slate 800 Solid
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_rounded,
              size: 160,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.videocam_rounded,
                    color: AppColors.accent,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kamera tidak tersedia',
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
      ),
    );
  }
}

/// Custom painter overlay untuk bingkai panduan oval berwarna Kuning
class _OvalGuideOverlay extends StatelessWidget {
  const _OvalGuideOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: _OvalOverlayPainter());
  }
}

class _OvalOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Dimensi oval panduan wajah
    final ovalWidth = size.width * 0.72;
    final ovalHeight = size.height * 0.52;
    final center = Offset(size.width / 2, size.height * 0.44);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    // Buat path layar penuh lalu kurangi area oval (cutout)
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addOval(ovalRect);

    final combinedPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      ovalPath,
    );

    // Gambar background redup di luar oval
    canvas.drawPath(combinedPath, backgroundPaint);

    // Gambar bingkai oval berwarna Kuning
    canvas.drawOval(ovalRect, borderPaint);

    // Gambar 4 sudut pembantu fokus di sekeliling oval
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const cornerLength = 16.0;
    // Top
    canvas.drawLine(
      Offset(center.dx - cornerLength, ovalRect.top + 8),
      Offset(center.dx + cornerLength, ovalRect.top + 8),
      cornerPaint,
    );
    // Bottom
    canvas.drawLine(
      Offset(center.dx - cornerLength, ovalRect.bottom - 8),
      Offset(center.dx + cornerLength, ovalRect.bottom - 8),
      cornerPaint,
    );
    // Left
    canvas.drawLine(
      Offset(ovalRect.left + 8, center.dy - cornerLength),
      Offset(ovalRect.left + 8, center.dy + cornerLength),
      cornerPaint,
    );
    // Right
    canvas.drawLine(
      Offset(ovalRect.right - 8, center.dy - cornerLength),
      Offset(ovalRect.right - 8, center.dy + cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
