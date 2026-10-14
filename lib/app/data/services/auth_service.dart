import 'package:get/get.dart';
import '../../core/constants/storage_constants.dart';
import '../../routes/app_routes.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();

  final RxBool _isLoggedIn = false.obs;
  final RxString _username = ''.obs;

  bool get isLoggedIn => _isLoggedIn.value;
  String get username => _username.value;

  @override
  void onInit() {
    super.onInit();
    _isLoggedIn.value =
        _storageService.read<bool>(StorageConstants.isLoggedIn) ?? false;
    _username.value =
        _storageService.read<String>(StorageConstants.username) ?? '';
  }

  /// Perform login and save state to local storage
  Future<void> login(String username) async {
    final cleanUsername = username.trim();
    await _storageService.write(StorageConstants.isLoggedIn, true);
    await _storageService.write(StorageConstants.username, cleanUsername);

    _isLoggedIn.value = true;
    _username.value = cleanUsername;
  }

  /// Perform logout and clear auth state
  Future<void> logout() async {
    await _storageService.write(StorageConstants.isLoggedIn, false);
    await _storageService.remove(StorageConstants.username);

    _isLoggedIn.value = false;
    _username.value = '';

    Get.offAllNamed(AppRoutes.login);
  }
}
