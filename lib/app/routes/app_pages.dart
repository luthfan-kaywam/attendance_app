import 'package:get/get.dart';
import '../../features/login/login_binding.dart';
import '../../features/login/login_view.dart';
import '../../features/home/home_binding.dart';
import '../../features/home/home_view.dart';
import '../../features/attendance_form/attendance_form_binding.dart';
import '../../features/attendance_form/attendance_form_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.attendanceForm,
      page: () => const AttendanceFormView(),
      binding: AttendanceFormBinding(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
