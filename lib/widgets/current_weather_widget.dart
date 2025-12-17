import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:neo_weather_new/models/weather_model.dart';
import 'package:neo_weather_new/ui/theme/colors.dart';
import 'package:neo_weather_new/ui/theme/styles.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrentWeatherWidget extends StatelessWidget {
  final Weather weather;

  const CurrentWeatherWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    // Expect weather.currentWeather (assumes your model has it)
    final current = weather.currentWeather;
    final daily = weather.dailyForecasts.isNotEmpty ? weather.dailyForecasts[0] : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppStyles.glassCardDecoration(),
          child: Column(
            children: [
              // Temp + Icon Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current.temperature.toStringAsFixed(1)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 6),
                    child: Text(
                      '°C',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getWeatherDescription(current.weatherCode),
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWeatherInfo(
                    'Wind',
                    '${current.windSpeed.toStringAsFixed(1)} km/h',
                    Icons.air,
                  ),
                  _buildWeatherInfo(
                    'High',
                    daily != null ? '${daily.temperatureMax.toStringAsFixed(0)}°' : 'N/A',
                    Icons.arrow_upward,
                  ),
                  _buildWeatherInfo(
                    'Low',
                    daily != null ? '${daily.temperatureMin.toStringAsFixed(0)}°' : 'N/A',
                    Icons.arrow_downward,
                  ),
                  _buildWeatherInfo(
                    'Rain',
                    '${current.precipitation.toStringAsFixed(1)} mm',
                    Icons.water_drop,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 16),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
      ],
    );
  }

  String _getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }
}
