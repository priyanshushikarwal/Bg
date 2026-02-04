import 'package:flutter/material.dart';

/// Modern fintech color palette - minimal, clean, premium
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Accent Gradient (use sparingly)
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft Accent Gradients (for icon backgrounds only)
  static const Gradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient greenGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient pinkGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Backgrounds - Clean White Theme
  static const Color background = Color(0xFFF8FAFC); // Very light gray
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color sidebarBackground = Color(0xFF1E293B); // Slate dark
  static const Color sidebarSurface = Color(0xFF334155);

  // Text Colors - Clear Hierarchy
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xFF94A3B8);

  // Status Colors - Soft Pastels
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Borders - Subtle
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFF1F5F9);

  // Shadows - Soft
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);

  // Legacy compatibility (remove these gradually)
  static const Color primaryPurple = primary;
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color primaryOrange = Color(0xFFF59E0B);
  static const Color glassBorder = border;
  static const Color hoverLight = Color(0xFFF8FAFC);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
  ];

  // Sidebar gradient (for compatibility)
  static const Gradient sidebarGradient = LinearGradient(
    colors: [sidebarBackground, sidebarBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
