import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary: Solid Blue (Tanpa Gradasi & Tanpa Ungu)
  static const Color primary = Color(0xFF1E40AF); // Blue 800
  static const Color primaryDark = Color(0xFF172554); // Blue 950
  static const Color primaryLight = Color(0xFFEFF6FF); // Blue 50

  // Accent / Secondary: Yellow / Amber
  static const Color accent = Color(0xFFF59E0B); // Amber 500 / Yellow 700
  static const Color accentLight = Color(0xFFFEF3C7); // Amber 100
  static const Color secondary = Color(0xFFF59E0B); // Yellow/Amber

  // Background & Surface: Clean White
  static const Color background = Color(0xFFF8FAFC); // Slate 50 / Clean White
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Typography: Hitam / Dark Grey
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 / Black87
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Status colors remain within the blue, yellow, and black palette.
  static const Color hadir = Color(0xFF1E40AF); // Blue 800
  static const Color izin = Color(0xFFF59E0B); // Amber 500 (Kuning)
  static const Color sakit = Color(0xFF172554); // Blue 950
}
