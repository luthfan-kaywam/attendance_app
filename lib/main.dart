import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred screen orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize local date formatting (for Bahasa Indonesia)
  await initializeDateFormatting('id_ID', null);

  // Initialize GetStorage
  await GetStorage.init();

  // Register permanent services before app runs
  final storageService =
      await Get.putAsync<StorageService>(() async => StorageService(), permanent: true);
  Get.put<AuthService>(AuthService(), permanent: true);

  final isLoggedIn = storageService.read<bool>('is_logged_in') ?? false;

  runApp(DigitalAttendanceApp(initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.login));
}

class DigitalAttendanceApp extends StatelessWidget {
  final String initialRoute;

  const DigitalAttendanceApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Digital Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
