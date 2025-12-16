import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:neo_weather_new/services/weather_service.dart';
import 'package:neo_weather_new/services/location_service.dart';
import 'package:neo_weather_new/helpers/weather_advisory_helper.dart';
import 'package:neo_weather_new/services/notification_service.dart';

const String kWeatherBackgroundTask = 'weather_background_task';

class WeatherBackgroundWorker {
  WeatherBackgroundWorker._();
  static final WeatherBackgroundWorker _instance = WeatherBackgroundWorker._();
  factory WeatherBackgroundWorker() => _instance;

  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  Future<void> register() async {
    await Workmanager().initialize(_callbackDispatcher, isInDebugMode: kDebugMode);
    await Workmanager().cancelByUniqueName(kWeatherBackgroundTask);
    await Workmanager().registerPeriodicTask(
      kWeatherBackgroundTask,
      kWeatherBackgroundTask,
      frequency: const Duration(hours: 3),
      initialDelay: const Duration(minutes: 5),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      WidgetsFlutterBinding.ensureInitialized();

      final NotificationService notificationService = NotificationService();
      await notificationService.init();

      final WeatherService weatherService = WeatherService();
      final LocationService locationService = LocationService();

      try {
        final currentPosition = await locationService.getCurrentLocation();
        final weather = await weatherService.fetchWeather(
          currentPosition.latitude,
          currentPosition.longitude,
        );

        final advisories = WeatherAdvisoryHelper.generate(weather);
        notificationService.showAdvisories('background_current', advisories);
      } catch (e, stack) {
        debugPrint('WeatherBackgroundWorker error: $e');
        debugPrint(stack.toString());
      }

      return Future.value(true);
    });
  }
}
