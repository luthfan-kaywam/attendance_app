import 'package:get/get.dart';
import '../../../app/core/constants/storage_constants.dart';
import '../../../app/data/services/storage_service.dart';
import '../../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthentication();
  }

  /// Menunggu 2.5 detik lalu memeriksa status login pengguna
  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    final isLoggedIn =
        _storageService.read<bool>(StorageConstants.isLoggedIn) ?? false;

    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
