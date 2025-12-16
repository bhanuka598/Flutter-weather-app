import 'package:flutter/material.dart';

class WeatherHelper {
  /// Returns a readable weather status text from WMO code
  static String getWeatherStatus(int code) {
    if (code == 0) return "Clear sky";
    if ([1, 2, 3].contains(code)) return "Partly cloudy";
    if ([45, 48].contains(code)) return "Fog";
    if ([51, 53, 55].contains(code)) return "Drizzle";
    if ([56, 57].contains(code)) return "Freezing Drizzle";
    if ([61, 63, 65].contains(code)) return "Rain";
    if ([66, 67].contains(code)) return "Freezing Rain";
    if ([71, 73, 75].contains(code)) return "Snowfall";
    if (code == 77) return "Snow grains";
    if ([80, 81, 82].contains(code)) return "Rain showers";
    if ([85, 86].contains(code)) return "Snow showers";
    if (code == 95) return "Thunderstorm";
    if ([96, 99].contains(code)) return "Severe Thunderstorm";

    return "Unknown";
  }

  /// Returns an icon based on WMO code
  static IconData getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny; // Clear
    if ([1, 2, 3].contains(code)) return Icons.cloud; // Cloudy
    if ([45, 48].contains(code)) return Icons.cloud_queue; // Fog
    if ([51, 53, 55].contains(code)) return Icons.grain; // Drizzle
    if ([61, 63, 65].contains(code)) return Icons.water_drop; // Rain
    if ([66, 67].contains(code)) return Icons.ac_unit; // Freezing rain
    if ([71, 73, 75, 77].contains(code)) return Icons.ac_unit; // Snow
    if ([80, 81, 82].contains(code)) return Icons.shower; // Rain shower
    if ([85, 86].contains(code)) return Icons.cloudy_snowing; // Snow shower
    if ([95, 96, 99].contains(code)) return Icons.thunderstorm; // Thunderstorm

    return Icons.help_outline;
  }

  /// Background gradient depending on weather
  static List<Color> getBackgroundColors(int code) {
    if (code == 0) {
      return [Colors.blue.shade300, Colors.yellow.shade600];
    }
    if ([1, 2, 3].contains(code)) {
      return [Colors.blueGrey.shade400, Colors.grey.shade700];
    }
    if ([61, 63, 65, 80, 81, 82].contains(code)) {
      return [Colors.indigo.shade700, Colors.blueGrey.shade900];
    }
    if ([71, 73, 75].contains(code)) {
      return [Colors.lightBlue.shade200, Colors.white];
    }
    if ([95, 96, 99].contains(code)) {
      return [Colors.deepPurple.shade900, Colors.black];
    }

    return [Colors.blueGrey.shade600, Colors.grey.shade800];
  }
}
