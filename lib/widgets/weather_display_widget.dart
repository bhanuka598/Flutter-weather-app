import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_weather_new/models/weather_model.dart';
import 'package:neo_weather_new/ui/theme/colors.dart';

class WeatherDisplayWidget extends StatelessWidget {
  final Weather weather;

  const WeatherDisplayWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final current = weather.currentWeather;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondaryCard.withOpacity(0.35),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${current.temperature.toStringAsFixed(1)}°",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Wind: ${current.windSpeed.toStringAsFixed(0)} km/h",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Text(
                "Rain: ${current.rain.toStringAsFixed(1)} mm",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
