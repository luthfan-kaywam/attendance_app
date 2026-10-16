import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/core/theme/app_theme.dart';
import 'app/data/services/attendance_service.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/storage_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientasi layar potret
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inisialisasi format tanggal lokal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi GetStorage satu kali tanpa error
  await GetStorage.init();

  // Daftarkan service utama sebelum aplikasi dijalankan
  await Get.putAsync<StorageService>(() async => StorageService(), permanent: true);
  await Get.putAsync<AttendanceService>(
    () async => await AttendanceService().init(),
    permanent: true,
  );
  Get.put<AuthService>(AuthService(), permanent: true);

  runApp(const DigitalAttendanceApp());
}

class DigitalAttendanceApp extends StatelessWidget {
  const DigitalAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Digital Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
