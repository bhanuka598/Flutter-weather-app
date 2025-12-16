import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:neo_weather_new/models/weather_model.dart';

class WeatherService {
  static const String _host = 'api.open-meteo.com';
  static const String _forecastPath = '/v1/forecast';
  final http.Client _httpClient;

  WeatherService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<Weather> fetchWeather(double latitude, double longitude) async {
    final standardQuery = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current_weather': 'true',
      'daily': 'weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,rain_sum',
      'hourly': 'temperature_2m,precipitation_probability,rain,showers,windspeed_10m,weathercode',
      'timezone': 'auto',
    };
    final fallbackQuery = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current_weather': 'true',
      'daily': 'weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,rain_sum',
      'hourly': 'time,temperature_2m,precipitation_probability,windspeed_10m',
      'timezone': 'auto',
    };
    final minimalQuery = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current_weather': 'true',
      'daily': 'weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,rain_sum',
      'hourly': 'time,temperature_2m,windspeed_10m',
      'timezone': 'auto',
    };
    final dailyOnlyQuery = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current_weather': 'true',
      'daily': 'weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,rain_sum',
      'timezone': 'auto',
    };

    try {
      return await _performRequest(standardQuery);
    } on WeatherApiException catch (error) {
      if (error.statusCode == 400) {
        debugPrint('WeatherService → Retrying with fallback query due to 400: ${error.message}');
        try {
          return await _performRequest(fallbackQuery);
        } on WeatherApiException catch (secondError) {
          if (secondError.statusCode == 400) {
            debugPrint('WeatherService → Retrying with minimal query due to 400: ${secondError.message}');
            try {
              return await _performRequest(minimalQuery);
            } on WeatherApiException catch (thirdError) {
              if (thirdError.statusCode == 400) {
                debugPrint('WeatherService → Retrying with daily-only query due to 400: ${thirdError.message}');
                return await _performRequest(dailyOnlyQuery);
              }
              rethrow;
            }
          }
          rethrow;
        }
      }
      rethrow;
    }
  }

  void dispose() {
    _httpClient.close();
  }

  Future<Weather> _performRequest(Map<String, String> params) async {
    final uri = Uri.https(_host, _forecastPath, params);
    try {
      debugPrint('WeatherService → Request: $uri');
      final response = await _httpClient.get(uri);
      debugPrint('WeatherService ← Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw WeatherApiException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['current_weather'] == null) {
        throw WeatherApiException(
          statusCode: response.statusCode,
          message: 'Weather data missing "current_weather" section',
        );
      }

      return Weather.fromJson(data);
    } catch (error, stackTrace) {
      debugPrint('WeatherService error: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }
}

class WeatherApiException implements Exception {
  final int statusCode;
  final String message;

  WeatherApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'WeatherApiException($statusCode): $message';
}
