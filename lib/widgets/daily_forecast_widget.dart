import 'package:flutter/material.dart';
import 'package:neo_weather_new/models/weather_model.dart';

class DailyForecastWidget extends StatelessWidget {
  final Weather weather;

  const DailyForecastWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather.dailyForecasts.isEmpty) {
      return const SizedBox.shrink(); // Or show a loading/empty state
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: const Color.fromRGBO(255, 255, 255, 0.1) ,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7-Day Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...weather.dailyForecasts.map((forecast) {
              return _buildForecastItem(
                date: forecast.date,
                minTemp: forecast.temperatureMin,
                maxTemp: forecast.temperatureMax,
                weatherCode: forecast.weatherCode,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem({
    required DateTime date,
    required double minTemp,
    required double maxTemp,
    required int weatherCode,
  }) {
    final dayOfWeek = _getDayOfWeek(date.weekday);
    final isToday = DateTime.now().day == date.day;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              isToday ? 'Today' : dayOfWeek,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _getWeatherIcon(weatherCode),
          Row(
            children: [
              Text(
                '${maxTemp.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${minTemp.round()}°',
                style: TextStyle(
                  color: const Color.fromRGBO(255, 255, 255, 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getWeatherIcon(int weatherCode) {
    // Map weather codes to appropriate icons
    if (weatherCode >= 1 && weatherCode <= 3) {
      return const Icon(Icons.wb_cloudy, color: Colors.white, size: 24);
    } else if (weatherCode >= 45 && weatherCode <= 48) {
      return const Icon(Icons.foggy, color: Colors.white, size: 24);
    } else if (weatherCode >= 51 && weatherCode <= 67) {
      return const Icon(Icons.grain, color: Colors.white, size: 24);
    } else if (weatherCode >= 71 && weatherCode <= 77) {
      return const Icon(Icons.ac_unit, color: Colors.white, size: 24);
    } else if (weatherCode >= 80 && weatherCode <= 86) {
      return const Icon(Icons.thunderstorm, color: Colors.white, size: 24);
    } else if (weatherCode >= 95 && weatherCode <= 99) {
      return const Icon(Icons.flash_on, color: Colors.white, size: 24);
    }
    // Default to sunny/clear
    return const Icon(Icons.wb_sunny, color: Colors.amber, size: 24);
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
