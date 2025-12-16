import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBg = Color(0xFF000000); // 60%
  static const Color secondaryCard = Color(0xFF1A1A2E); // 30%
  static const Color accent = Color(0xFF4A9EFF); // 10%

  // Derived translucent colors for glass effect
  static Color glassCard = secondaryCard.withOpacity(0.22);
  static Color glassSurface = Colors.white.withOpacity(0.06);
  static Color cardBorder = Colors.white.withOpacity(0.08);
}
