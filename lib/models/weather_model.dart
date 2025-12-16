import 'package:flutter/material.dart';

class Weather {
  final List<HourlyWeather> hourlyForecasts;
  final List<DailyWeather> dailyForecasts;
  final String? timezone;

  Weather({
    required this.hourlyForecasts,
    required this.dailyForecasts,
    this.timezone,
  });

  // 👇 Auto-generated current weather (uses earliest hourly entry)
  HourlyWeather get currentWeather => hourlyForecasts.first;

  factory Weather.fromJson(Map<String, dynamic> json) {
    // --- Hourly ---
    final hourly = json["hourly"] as Map<String, dynamic>;
    final times = List<String>.from(hourly["time"]);
    final temps = List<num>.from(hourly["temperature_2m"]);
    final rain = List<num>.from(hourly["rain"] ?? hourly["rainfall"] ?? []);
    final precipitation = List<num>.from(hourly["precipitation_probability"]);
    final wind = List<num>.from(hourly["windspeed_10m"]);
    final weatherCodes = List<int>.from(hourly["weathercode"]);

    final hourlyForecasts = List.generate(times.length, (i) => HourlyWeather(
      time: DateTime.parse(times[i]),
      temperature: temps[i].toDouble(),
      rain: rain.isNotEmpty ? rain[i].toDouble() : 0.0,
      precipitationProbability: precipitation[i].toDouble(),
      windSpeed: wind[i].toDouble(),
      weatherCode: weatherCodes[i],
    ));

    // --- Daily ---
    final daily = json["daily"] as Map<String, dynamic>;
    final dates = List<String>.from(daily["time"]);
    final maxTemps = List<num>.from(daily["temperature_2m_max"]);
    final minTemps = List<num>.from(daily["temperature_2m_min"]);
    final uvMax = List<num>.from(daily["uv_index_max"] ?? []);
    final weatherDailyCodes = List<int>.from(daily["weathercode"]);
    final sunrise = List<String>.from(daily["sunrise"] ?? []);
    final sunset = List<String>.from(daily["sunset"] ?? []);

    final dailyForecasts = List.generate(dates.length, (i) => DailyWeather(
      date: DateTime.parse(dates[i]),
      temperatureMax: maxTemps[i].toDouble(),
      temperatureMin: minTemps[i].toDouble(),
      rainSum: 0.0,
      uvIndexMax: uvMax.isNotEmpty ? uvMax[i].toDouble() : null,
      weatherCode: weatherDailyCodes[i],
    ));

    return Weather(
      hourlyForecasts: hourlyForecasts,
      dailyForecasts: dailyForecasts,
      timezone: json["timezone"],
    );
  }
}

// ============================================================
//                     HOURLY WEATHER MODEL
// ============================================================
class HourlyWeather {
  final DateTime time;
  final double temperature;                 // °C
  final double rain;                        // mm
  final double precipitationProbability;    // %
  final double windSpeed;                   // km/h
  final double? uvIndex;                    // can be null
  final int weatherCode;                    // numeric weather condition

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.rain,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.weatherCode,
    this.uvIndex,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: DateTime.parse(json["time"]),
      temperature: (json["temperature"] as num).toDouble(),
      rain: (json["rain"] ?? 0).toDouble(),
      precipitationProbability:
      (json["precipitation_probability"] ?? 0).toDouble(),
      windSpeed: (json["wind_speed"] ?? 0).toDouble(),
      uvIndex: json["uv_index"] != null ? (json["uv_index"] as num).toDouble() : null,
      weatherCode: json["weather_code"] ?? 0,
    );
  }
}

// ============================================================
//                     DAILY WEATHER MODEL
// ============================================================
class DailyWeather {
  final DateTime date;
  final double temperatureMax;
  final double temperatureMin;
  final double rainSum;
  final double? uvIndexMax;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.rainSum,
    required this.weatherCode,
    this.uvIndexMax,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      date: DateTime.parse(json["date"]),
      temperatureMax: (json["temperature_max"] as num).toDouble(),
      temperatureMin: (json["temperature_min"] as num).toDouble(),
      rainSum: (json["rain_sum"] ?? 0).toDouble(),
      uvIndexMax:
      json["uv_index_max"] != null ? (json["uv_index_max"] as num).toDouble() : null,
      weatherCode: json["weather_code"] ?? 0,
    );
  }
}
