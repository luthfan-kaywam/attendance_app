import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/core/constants/app_strings.dart';
import '../../app/core/theme/app_colors.dart';
import '../../app/core/utils/validators.dart';
import '../../app/core/widgets/app_logo.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 36),
                _buildForm(),
                const SizedBox(height: 28),
                _buildLoginButton(),
                const SizedBox(height: 24),
                _buildFooterNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header dengan Logo Baru & Tipografi Tegas ────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo baru resmi aplikasi (Biru Solid + Aksen Kuning)
        const AppLogo(size: 68, showBadge: true),
        const SizedBox(height: 24),
        const Text(
          AppStrings.loginTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppStrings.loginSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ─── Form Input (Validasi Ketat) ──────────────────────────────────────────
  Widget _buildForm() {
    return Form(
      key: controller.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username / Email Field
          _buildFieldLabel(AppStrings.usernameLabel),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.usernameController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            validator: Validators.validateUsername,
            decoration: const InputDecoration(
              hintText: AppStrings.usernameHint,
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Password Field
          _buildFieldLabel(AppStrings.passwordLabel),
          const SizedBox(height: 8),
          Obx(() => TextFormField(
                controller: controller.passwordController,
                obscureText: controller.isPasswordHidden.value,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                onFieldSubmitted: (_) => controller.submitLogin(),
                validator: Validators.validatePassword,
                decoration: InputDecoration(
                  hintText: AppStrings.passwordHint,
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.primary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                    tooltip: controller.isPasswordHidden.value
                        ? 'Tampilkan password'
                        : 'Sembunyikan password',
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ─── Field Label ──────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  // ─── Tombol "Masuk Sekarang" (Biru Solid Tegas Tanpa Gradasi) ─────────────
  Widget _buildLoginButton() {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      return Container(
        height: 52,
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey.shade400 : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isLoading ? null : controller.submitLogin,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      AppStrings.loginButton,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Footer Note ──────────────────────────────────────────────────────────
  Widget _buildFooterNote() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'Gunakan akun resmi yang terdaftar oleh instansi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
