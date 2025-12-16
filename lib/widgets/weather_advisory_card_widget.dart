import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:neo_weather_new/helpers/weather_advisory_helper.dart';
import 'package:neo_weather_new/ui/theme/colors.dart';
import 'package:neo_weather_new/ui/theme/styles.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherAdvisoryCard extends StatelessWidget {
  final WeatherAdvisory advisory;
  const WeatherAdvisoryCard({super.key, required this.advisory});

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(advisory.category);
    final catColor = _colorFor(advisory.category);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: AppStyles.glassCardDecoration(),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: catColor, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advisory.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      advisory.description,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 36,
                width: 36,
                decoration: AppStyles.accentGlow(),
                child: Icon(Icons.chevron_right, color: Colors.white70, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AdvisoryCategory c) {
    switch (c) {
      case AdvisoryCategory.rain:
        return Icons.umbrella;
      case AdvisoryCategory.heat:
        return Icons.wb_sunny;
      case AdvisoryCategory.cold:
        return Icons.ac_unit;
      case AdvisoryCategory.wind:
        return Icons.air;
      case AdvisoryCategory.uv:
        return Icons.wb_iridescent;
      case AdvisoryCategory.laundry:
        return Icons.local_laundry_service;
      case AdvisoryCategory.commute:
        return Icons.directions_bus;
      case AdvisoryCategory.fitness:
        return Icons.directions_run;
      case AdvisoryCategory.weekend:
        return Icons.event_available;
      case AdvisoryCategory.night:
        return Icons.nights_stay;
      default:
        return Icons.info;
    }
  }

  Color _colorFor(AdvisoryCategory c) {
    switch (c) {
      case AdvisoryCategory.rain:
        return const Color(0xFF4FC3F7);
      case AdvisoryCategory.heat:
        return const Color(0xFFFFA726);
      case AdvisoryCategory.cold:
        return const Color(0xFF9FA8DA);
      case AdvisoryCategory.wind:
        return const Color(0xFF80DEEA);
      case AdvisoryCategory.uv:
        return const Color(0xFFF06292);
      case AdvisoryCategory.laundry:
        return const Color(0xFF81C784);
      case AdvisoryCategory.commute:
        return const Color(0xFF64B5F6);
      case AdvisoryCategory.fitness:
        return const Color(0xFFAED581);
      case AdvisoryCategory.weekend:
        return const Color(0xFFFFCC80);
      case AdvisoryCategory.night:
        return const Color(0xFF9575CD);
      default:
        return AppColors.accent;
    }
  }
}
