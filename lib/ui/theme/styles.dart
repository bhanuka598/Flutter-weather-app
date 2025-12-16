import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppStyles {
  static TextStyle heading({double size = 18}) =>
      GoogleFonts.poppins(color: Colors.white, fontSize: size, fontWeight: FontWeight.w600);

  static TextStyle subHeading({double size = 14}) =>
      GoogleFonts.poppins(color: Colors.white70, fontSize: size, fontWeight: FontWeight.w500);

  static BoxDecoration glassCardDecoration({double blur = 12.0}) {
    return BoxDecoration(
      color: AppColors.glassCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cardBorder),
      boxShadow: [
        BoxShadow(
          color: AppColors.accent.withOpacity(0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration accentGlow() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.accent.withOpacity(0.18),
          AppColors.accent.withOpacity(0.06),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.accent.withOpacity(0.22),
          blurRadius: 20,
          offset: const Offset(0, 8),
        )
      ],
    );
  }
}
