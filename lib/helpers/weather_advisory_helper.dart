import 'package:intl/intl.dart';
import 'package:neo_weather_new/models/weather_model.dart';

enum AdvisoryCategory {
  rain,
  heat,
  cold,
  wind,
  uv,
  laundry,
  commute,
  fitness,
  weekend,
  night,
  hourlyChange,
}

class WeatherAdvisory {
  final AdvisoryCategory category;
  final String title;
  final String description;

  const WeatherAdvisory({
    required this.category,
    required this.title,
    required this.description,
  });
}

class WeatherAdvisoryHelper {
  static final DateFormat _timeFormat = DateFormat.Hm();
  static final DateFormat _dayFormat = DateFormat('EEEE');

  // ---------------- DAILY + HOURLY COMBINED ----------------
  static List<WeatherAdvisory> generate(Weather weather, {DateTime? referenceTime}) {
    final advisories = <WeatherAdvisory>[];

    advisories.addAll(_dailyAdvisories(weather, referenceTime));
    advisories.addAll(_hourlyChangeAdvisories(weather));

    return advisories;
  }

  // ============================================================
  //                   DAILY ADVISORIES
  // ============================================================
  static List<WeatherAdvisory> _dailyAdvisories(Weather weather, DateTime? ref) {
    final now = ref ?? DateTime.now();
    final list = <WeatherAdvisory>[];

    if (weather.hourlyForecasts.isEmpty || weather.dailyForecasts.isEmpty) {
      return list;
    }

    final today = weather.dailyForecasts.first;
    final nextHours = weather.hourlyForecasts
        .where((h) => h.time.isAfter(now) && h.time.isBefore(now.add(const Duration(hours: 24))))
        .toList();

    if (nextHours.isEmpty) return list;

    // --- Rain Detection ---
    final hasRain = nextHours.any((h) => h.precipitationProbability >= 60 || h.rain > 0);

    if (hasRain) {
      final firstRain = nextHours.firstWhere(
            (h) => h.precipitationProbability >= 60 || h.rain > 0,
      );

      final minutesUntil = firstRain.time.difference(now).inMinutes;
      final whenText =
      minutesUntil <= 60 ? "within the next hour" : "around ${_timeFormat.format(firstRain.time)}";

      list.add(
        WeatherAdvisory(
          category: AdvisoryCategory.rain,
          title: '🌧 Rain on the way',
          description: 'Expect showers $whenText. Keep an umbrella if heading out.',
        ),
      );
    }

    // --- Strong Heat ---
    if (today.temperatureMax >= 33) {
      list.add(
        const WeatherAdvisory(
          category: AdvisoryCategory.heat,
          title: '🔥 High heat today',
          description:
          'Feels hot outside. Drink plenty of water & avoid direct sunlight at midday.',
        ),
      );
    }

    // --- UV High ---
    if ((today.uvIndexMax ?? 0) >= 8) {
      list.add(
        WeatherAdvisory(
          category: AdvisoryCategory.uv,
          title: '🟣 UV index very high',
          description:
          'UV peaks at ${(today.uvIndexMax ?? 0).toStringAsFixed(0)} — wear sunscreen & sunglasses.',
        ),
      );
    }

    // --- Cold Night ---
    if (today.temperatureMin <= 18) {
      list.add(
        const WeatherAdvisory(
          category: AdvisoryCategory.cold,
          title: '❄️ Chilly night ahead',
          description: 'Cooler temperatures expected tonight. Take a light jacket.',
        ),
      );
    }

    // --- Wind ---
    if (nextHours.any((h) => h.windSpeed >= 35)) {
      final windyHour =
      nextHours.firstWhere((h) => h.windSpeed >= 35, orElse: () => nextHours.first);

      list.add(
        WeatherAdvisory(
          category: AdvisoryCategory.wind,
          title: '💨 Strong winds today',
          description:
          'Winds may reach ${windyHour.windSpeed.toStringAsFixed(0)} km/h around ${_timeFormat.format(windyHour.time)}.',
        ),
      );
    }

    // --- Laundry ---
    final eveningRain = nextHours.any((h) =>
    (h.time.hour >= 17 && h.time.hour <= 21) &&
        (h.precipitationProbability >= 50 || h.rain > 0.5));

    if (!eveningRain && !hasRain) {
      list.add(
        const WeatherAdvisory(
          category: AdvisoryCategory.laundry,
          title: '👕 Good day for drying clothes',
          description: 'Low rain chance today — perfect for drying clothes outside.',
        ),
      );
    } else if (eveningRain) {
      list.add(
        const WeatherAdvisory(
          category: AdvisoryCategory.laundry,
          title: '🌧 Evening rain expected',
          description: 'Avoid leaving clothes outside — showers expected later.',
        ),
      );
    }

    // --- Commute Morning ---
    final morningRain = _firstRainDuringWindow(nextHours, 7, 10);
    if (morningRain != null) {
      list.add(
        WeatherAdvisory(
          category: AdvisoryCategory.commute,
          title: '🚗 Morning commute rain',
          description:
          'Rain expected around ${_timeFormat.format(morningRain.time)} — carry an umbrella.',
        ),
      );
    }

    // --- Commute Evening ---
    final eveningCommuteRain = _firstRainDuringWindow(nextHours, 17, 21);
    if (eveningCommuteRain != null) {
      list.add(
        WeatherAdvisory(
          category: AdvisoryCategory.commute,
          title: '🚗 Evening rain alert',
          description:
          'Showers likely around ${_timeFormat.format(eveningCommuteRain.time)} — plan for delays.',
        ),
      );
    }

    // --- Fitness weather ---
    if (today.temperatureMax <= 30 && today.temperatureMin >= 20 && !hasRain) {
      list.add(
        const WeatherAdvisory(
          category: AdvisoryCategory.fitness,
          title: '🏃 Good weather for exercise',
          description: 'Mild temperatures and low rain — great for jogging or walking.',
        ),
      );
    }

    // --- Weekend weather ---
    final upcomingWeekend = weather.dailyForecasts.firstWhere(
          (d) => d.date.isAfter(now) && (d.date.weekday == DateTime.saturday || d.date.weekday == DateTime.sunday),
      orElse: () => today,
    );

    if (upcomingWeekend.date.weekday == DateTime.saturday ||
        upcomingWeekend.date.weekday == DateTime.sunday) {
      final good = upcomingWeekend.weatherCode <= 2 && upcomingWeekend.temperatureMax < 34;

      list.add(
        WeatherAdvisory(
          category: AdvisoryCategory.weekend,
          title: good ? '🌤 Great weekend ahead' : '🌧 Rainy weekend expected',
          description: good
              ? '${_dayFormat.format(upcomingWeekend.date)} looks perfect for outdoor plans!'
              : 'Expect some rain during the weekend — consider indoor plans.',
        ),
      );
    }

    // --- Night cold ---
    if (today.temperatureMin <= 20) {
      list.add(
        const WeatherAdvisory(
          category: AdvisoryCategory.night,
          title: '🌙 Cool night ahead',
          description: 'Temperatures drop below 20°C tonight — close windows if needed.',
        ),
      );
    }

    return list;
  }

  // ============================================================
  //                     HOURLY CHANGE ADVISORIES
  // ============================================================
  static List<WeatherAdvisory> _hourlyChangeAdvisories(Weather weather) {
    final advisories = <WeatherAdvisory>[];

    final hours = weather.hourlyForecasts;
    if (hours.length < 2) return advisories;

    for (int i = 1; i < hours.length; i++) {
      final prev = hours[i - 1];
      final current = hours[i];

      final timeText = _timeFormat.format(current.time);

      // Temp rise
      final tempRise = current.temperature - prev.temperature;
      if (tempRise >= 3) {
        advisories.add(
          WeatherAdvisory(
            category: AdvisoryCategory.hourlyChange,
            title: '🔥 Temperature rising',
            description:
            'Temperature increases by ${tempRise.toStringAsFixed(1)}°C at $timeText.',
          ),
        );
      }

      // Temp drop
      final tempDrop = prev.temperature - current.temperature;
      if (tempDrop >= 3) {
        advisories.add(
          WeatherAdvisory(
            category: AdvisoryCategory.hourlyChange,
            title: '❄️ Temperature dropping fast',
            description:
            'Expect a ${tempDrop.toStringAsFixed(1)}°C drop around $timeText.',
          ),
        );
      }

      // Rain starting
      if ((prev.rain == 0 && current.rain > 0.2) ||
          (prev.precipitationProbability < 40 && current.precipitationProbability >= 60)) {
        advisories.add(
          WeatherAdvisory(
            category: AdvisoryCategory.hourlyChange,
            title: '🌧 Rain starting',
            description: 'Rain expected to begin around $timeText — take an umbrella.',
          ),
        );
      }

      // Rain stopping
      if ((prev.rain > 0.2 && current.rain == 0) ||
          (prev.precipitationProbability >= 60 && current.precipitationProbability < 40)) {
        advisories.add(
          WeatherAdvisory(
            category: AdvisoryCategory.hourlyChange,
            title: '🌤 Rain clearing',
            description: 'Rain stops around $timeText — weather improving.',
          ),
        );
      }

      // Wind increase
      final windIncrease = current.windSpeed - prev.windSpeed;
      if (windIncrease >= 15) {
        advisories.add(
          WeatherAdvisory(
            category: AdvisoryCategory.hourlyChange,
            title: '💨 Winds increasing',
            description:
            'Wind rises by ${windIncrease.toStringAsFixed(0)} km/h at $timeText.',
          ),
        );
      }

      // UV spike
      if (current.uvIndex != null &&
          prev.uvIndex != null &&
          current.uvIndex! - prev.uvIndex! >= 2) {
        advisories.add(
          WeatherAdvisory(
            category: AdvisoryCategory.hourlyChange,
            title: '🟣 UV spike',
            description:
            'UV index rises sharply around $timeText — protect your skin.',
          ),
        );
      }
    }

    return advisories;
  }

  // Utility
  static HourlyWeather? _firstRainDuringWindow(
      List<HourlyWeather> hours,
      int startHour,
      int endHour,
      ) {
    for (final hour in hours) {
      final h = hour.time.hour;
      if (h >= startHour && h <= endHour) {
        if (hour.precipitationProbability >= 50 || hour.rain > 0.5) {
          return hour;
        }
      }
    }
    return null;
  }
}
