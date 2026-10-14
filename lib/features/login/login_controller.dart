import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/data/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    usernameController.dispose();
    super.onClose();
  }

  Future<void> submitLogin() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      await _authService.login(usernameController.text);

      Get.offAllNamed(AppRoutes.home);
      Get.snackbar(
        'Berhasil',
        'Selamat datang kembali, ${_authService.username}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
