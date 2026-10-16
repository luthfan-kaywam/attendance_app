import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/core/theme/app_colors.dart';
import '../../app/data/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // --- Form ---
  final formKey = GlobalKey<FormState>();

  // --- Controllers (wajib di-dispose untuk mencegah memory leak) ---
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // --- Reactive state ---
  final RxBool isPasswordHidden = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    // Selalu dispose TextEditingController agar tidak memory leak
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Toggle visibilitas karakter password
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// Submit form login:
  /// 1. Validasi semua field via formKey
  /// 2. Set loading, panggil AuthService.login(username)
  /// 3. Navigasi ke /home dan tampilkan snackbar sambutan
  Future<void> submitLogin() async {
    // Tutup keyboard terlebih dahulu
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Simulasi network delay (hapus jika sudah pakai API nyata)
      await Future.delayed(const Duration(milliseconds: 600));

      await _authService.login(usernameController.text.trim());

      Get.offAllNamed(AppRoutes.home);

      Get.snackbar(
        'Selamat Datang! 👋',
        'Halo, ${_authService.username}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.hadir,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_outline_rounded,
            color: Colors.white, size: 28),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Masuk',
        'Terjadi kesalahan, silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.sakit,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
