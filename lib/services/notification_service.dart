import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:neo_weather_new/helpers/weather_advisory_helper.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  final Map<String, String> _lastShownPayload = {};

  static const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
    'weather_advisories',
    'Weather advisories',
    description: 'Notifications generated from smart weather tips',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: darwinSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);

    _initialized = true;
  }

  Future<void> showAdvisories(String key, List<WeatherAdvisory> advisories) async {
    if (!_initialized || advisories.isEmpty) return;

    final payloadKey = advisories.map((a) => '${a.category.name}:${a.title}').join('|');
    if (_lastShownPayload[key] == payloadKey) {
      return;
    }

    _lastShownPayload[key] = payloadKey;

    final headline = advisories.first.title;
    final bodyLines = advisories.map((a) => '• ${a.description}').take(3).toList();
    final body = bodyLines.join('\n');

    final androidDetails = AndroidNotificationDetails(
      _defaultChannel.id,
      _defaultChannel.name,
      channelDescription: _defaultChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: body.isEmpty ? null : BigTextStyleInformation('$headline\n$body'),
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.show(
      key.hashCode & 0x7fffffff,
      headline,
      advisories.first.description,
      notificationDetails,
    );
  }
}
