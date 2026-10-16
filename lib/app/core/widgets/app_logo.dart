import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBadge;

  const AppLogo({
    super.key,
    this.size = 72,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer decorative ring in clean yellow
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size * 0.28),
            border: Border.all(color: AppColors.accent, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.fingerprint_rounded,
              color: Colors.white,
              size: size * 0.58,
            ),
          ),
        ),
        // Mini verification check badge
        if (showBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(size * 0.05),
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.textPrimary,
                size: size * 0.22,
              ),
            ),
          ),
      ],
    );
  }
}
