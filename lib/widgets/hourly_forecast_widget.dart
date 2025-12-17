import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neo_weather_new/models/weather_model.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyWeather> hourlyForecasts;
  final String timezone;

  const HourlyForecastWidget({
    Key? key,
    required this.hourlyForecasts,
    required this.timezone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize timezone database
    tz.initializeTimeZones();
    
    if (hourlyForecasts.isEmpty) {
      if (kDebugMode) {
        print('No hourly forecasts available');
      }
      return const SizedBox.shrink();
    }

    // Get next 24 hours of forecasts
    final now = DateTime.now().toUtc();
    List<HourlyWeather> next24Hours;
    
    try {
      next24Hours = hourlyForecasts
          .where((forecast) => forecast.time.isAfter(now.subtract(const Duration(hours: 1))))
          .take(24)
          .toList();
          
      if (next24Hours.isEmpty && hourlyForecasts.isNotEmpty) {
        // If no future forecasts, show the most recent ones
        next24Hours = hourlyForecasts.take(24).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing hourly forecasts: $e');
      }
      return const SizedBox.shrink();
    }

    if (next24Hours.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: next24Hours.length,
            itemBuilder: (context, index) {
              final forecast = next24Hours[index];
              String time;
              try {
                if (timezone.isNotEmpty) {
                  // Convert UTC time to local timezone
                  final location = tz.getLocation(timezone);
                  final localTime = tz.TZDateTime.from(forecast.time, location);
                  time = DateFormat('ha').format(localTime);
                } else {
                  time = DateFormat('ha').format(forecast.time.toLocal());
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Error formatting time: $e');
                }
                time = '--';
              }
              
              return Container(
                width: 70,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      time,
                      style: const TextStyle(fontSize: 12),
                    ),
                    _buildWeatherIcon(forecast.weatherCode),
                    Text(
                      '${forecast.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (forecast.precipitation > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.water_drop, size: 12, color: Colors.blue),
                          const SizedBox(width: 2),
                          Text(
                            '${forecast.precipitation.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherIcon(int weatherCode) {
    // Map weather codes to appropriate icons
    IconData icon;
    switch (weatherCode) {
      case 0: // Clear sky
        icon = Icons.wb_sunny;
        break;
      case 1: // Mainly clear
      case 2: // Partly cloudy
        icon = Icons.wb_cloudy;
        break;
      case 3: // Overcast
        icon = Icons.cloud;
        break;
      case 45: // Fog
      case 48: // Depositing rime fog
        icon = Icons.foggy;
        break;
      case 51: // Light drizzle
      case 53: // Moderate drizzle
      case 55: // Dense drizzle
      case 56: // Light freezing drizzle
      case 57: // Dense freezing drizzle
        icon = Icons.grain;
        break;
      case 61: // Slight rain
      case 63: // Moderate rain
      case 65: // Heavy rain
      case 80: // Slight rain showers
      case 81: // Moderate rain showers
      case 82: // Violent rain showers
        icon = Icons.beach_access;
        break;
      case 66: // Light freezing rain
      case 67: // Heavy freezing rain
        icon = Icons.ac_unit;
        break;
      case 71: // Slight snow fall
      case 73: // Moderate snow fall
      case 75: // Heavy snow fall
      case 77: // Snow grains
      case 85: // Slight snow showers
      case 86: // Heavy snow showers
        icon = Icons.ac_unit;
        break;
      case 95: // Thunderstorm
      case 96: // Thunderstorm with slight hail
      case 99: // Thunderstorm with heavy hail
        icon = Icons.thunderstorm;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Icon(icon, size: 24);
  }
}
