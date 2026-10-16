import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CameraCaptureController extends GetxController {
  // ─── Camera Controller & Descriptions ─────────────────────────────────────
  CameraController? cameraController;
  List<CameraDescription> cameras = [];

  // ─── Reactive States ──────────────────────────────────────────────────────
  final RxBool isInitialized = false.obs;
  final RxBool isCameraAvailable = false.obs;
  final RxBool isFrontCamera = true.obs;
  final RxInt selectedCameraIndex = 0.obs;
  final RxString statusMessage = 'Menyiapkan kamera...'.obs;
  bool _isClosing = false;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  @override
  void onClose() {
    _isClosing = true;
    final activeController = cameraController;
    cameraController = null;
    activeController?.dispose();
    super.onClose();
  }

  /// Inisialisasi kamera asli perangkat (HP Android/iOS, Webcam Laptop/Browser)
  Future<void> initializeCamera() async {
    try {
      isInitialized.value = false;
      statusMessage.value = 'Mendeteksi sensor kamera...';

      cameras = await availableCameras();
      if (_isClosing) return;

      if (cameras.isNotEmpty) {
        // Cari kamera depan terlebih dahulu untuk verifikasi wajah
        int frontIndex = cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );

        int targetIndex = frontIndex >= 0 ? frontIndex : 0;
        selectedCameraIndex.value = targetIndex;
        isFrontCamera.value =
            cameras[targetIndex].lensDirection == CameraLensDirection.front;
        await _initCameraController(cameras[targetIndex]);
      } else {
        // Fallback prototype jika tidak ada kamera fisik terdeteksi
        isCameraAvailable.value = false;
        statusMessage.value =
            'Mode Sensor Prototype Aktif (Tanpa Kamera Fisik)';
      }
    } catch (e) {
      if (_isClosing) return;
      if (kDebugMode) {
        print('Camera initialization notice: $e');
      }
      isCameraAvailable.value = false;
      statusMessage.value = 'Mode Sensor Prototype Aktif';
    } finally {
      if (!_isClosing) isInitialized.value = true;
    }
  }

  /// Inisialisasi controller untuk kamera yang dipilih
  Future<void> _initCameraController(CameraDescription description) async {
    final prevController = cameraController;
    cameraController = null;
    await prevController?.dispose();
    if (_isClosing) return;

    final newController = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await newController.initialize();
      if (_isClosing) {
        await newController.dispose();
        return;
      }
      cameraController = newController;
      isCameraAvailable.value = true;
    } catch (e) {
      await newController.dispose();
      if (_isClosing) return;
      isCameraAvailable.value = false;
      if (kDebugMode) {
        print('CameraController init error: $e');
      }
    }
  }

  /// Beralih antara kamera depan dan belakang
  Future<void> toggleCamera() async {
    if (_isClosing) return;

    if (cameras.length <= 1) {
      // Toggle simulasi jika hanya 1 kamera atau mode prototype
      isFrontCamera.value = !isFrontCamera.value;
      return;
    }

    try {
      isInitialized.value = false;
      selectedCameraIndex.value =
          (selectedCameraIndex.value + 1) % cameras.length;
      final targetCamera = cameras[selectedCameraIndex.value];
      isFrontCamera.value =
          targetCamera.lensDirection == CameraLensDirection.front;

      await _initCameraController(targetCamera);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling camera: $e');
      }
    } finally {
      if (!_isClosing) isInitialized.value = true;
    }
  }

}
