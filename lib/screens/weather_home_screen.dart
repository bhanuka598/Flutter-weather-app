// lib/screens/weather_home_screen.dart
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:neo_weather_new/helpers/weather_advisory_helper.dart';
import 'package:neo_weather_new/models/weather_model.dart';
import 'package:neo_weather_new/services/location_service.dart';
import 'package:neo_weather_new/services/notification_service.dart';
import 'package:neo_weather_new/services/weather_service.dart';
import 'package:neo_weather_new/widgets/current_weather_widget.dart';
import 'package:neo_weather_new/widgets/hourly_forecast_widget.dart';
import 'package:neo_weather_new/widgets/daily_forecast_widget.dart';
import 'package:neo_weather_new/widgets/search_bar_widget.dart';
import 'package:neo_weather_new/widgets/loading_indicator.dart';
import 'package:neo_weather_new/widgets/weather_display_widget.dart';
import 'package:neo_weather_new/widgets/weather_error_widget.dart';
import 'package:neo_weather_new/widgets/weather_advisory_card_widget.dart';
import 'package:neo_weather_new/ui/theme/colors.dart';

class _CityWeatherEntry {
  final double latitude;
  final double longitude;
  final String displayName;
  final Weather weather;

  _CityWeatherEntry({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    required this.weather,
  });

  bool matchesCoordinates(double lat, double lon) {
    return (latitude - lat).abs() < 0.001 && (longitude - lon).abs() < 0.001;
  }
}

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();

  _CityWeatherEntry? _currentEntry;
  _CityWeatherEntry? _searchedEntry;
  List<WeatherAdvisory> _currentAdvisories = const [];
  List<WeatherAdvisory> _searchAdvisories = const [];

  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _fetchInitialWeather();
  }

  Future<void> _fetchInitialWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      final name = await _locationService.getCityName(position.latitude, position.longitude);
      final weather = await _weatherService.fetchWeather(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _currentEntry = _CityWeatherEntry(
          latitude: position.latitude,
          longitude: position.longitude,
          displayName: name,
          weather: weather,
        );
        _currentAdvisories = WeatherAdvisoryHelper.generate(weather);
        _notifyAdvisories('current_location', _currentAdvisories);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshCurrentLocation() async {
    final entry = _currentEntry;
    if (entry == null) {
      await _fetchInitialWeather();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await _weatherService.fetchWeather(entry.latitude, entry.longitude);
      final name = await _location_service_getCityNameSafe(entry.latitude, entry.longitude);

      if (!mounted) return;
      setState(() {
        _currentEntry = _CityWeatherEntry(
          latitude: entry.latitude,
          longitude: entry.longitude,
          displayName: name,
          weather: weather,
        );
        _currentAdvisories = WeatherAdvisoryHelper.generate(weather);
        _notifyAdvisories('current_location', _currentAdvisories);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Safe wrapper to get city name; keeps code resilient if service method changes
  Future<String> _location_service_getCityNameSafe(double lat, double lon) async {
    try {
      return await _location_service_getCityName(lat, lon);
    } catch (_) {
      return 'Current Location';
    }
  }

  // small internal stub (calls your LocationService)
  Future<String> _location_service_getCityName(double lat, double lon) {
    return _locationService.getCityName(lat, lon);
  }

  Future<void> _handleCitySearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
      _searchedEntry = null;
      _searchAdvisories = const [];
    });

    try {
      final coords = await _locationService.getCoordinatesForCity(q);
      final weather = await _weatherService.fetchWeather(coords.latitude, coords.longitude);

      final entry = _CityWeatherEntry(
        latitude: coords.latitude,
        longitude: coords.longitude,
        displayName: coords.displayName,
        weather: weather,
      );

      if (!mounted) return;

      setState(() {
        _searchedEntry = entry;
        _isSearching = false;
        _searchError = null;
        _searchAdvisories = WeatherAdvisoryHelper.generate(weather);
        _notifyAdvisories('search_${entry.displayName}', _searchAdvisories);
      });
    } catch (e, stack) {
      if (!mounted) return;
      if (kDebugMode) print("Error fetching city '$q': $e\n$stack");
      setState(() {
        _searchError = "Failed to fetch weather for '$q': $e";
        _isSearching = false;
        _searchAdvisories = const [];
      });
    }
  }

  void _notifyAdvisories(String key, List<WeatherAdvisory> advisories) {
    if (advisories.isEmpty) return;
    _notification_service_show(key, advisories);
  }

  // wrapper to send notifications
  void _notification_service_show(String key, List<WeatherAdvisory> advisories) {
    try {
      _notificationService.showAdvisories(key, advisories);
    } catch (_) {
      // ignore if notifications not available
    }
  }

  @override
  Widget build(BuildContext context) {
    tz.initializeTimeZones();

    final title = _searchedEntry?.displayName ??
        _currentEntry?.displayName ??
        (_isLoading ? 'Loading...' : 'Weather');

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              // Header row (title + actions)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : _refreshCurrentLocation,
                    icon: Icon(Icons.refresh, color: AppColors.accent),
                  ),
                ],
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: SearchBarWidget(
                  onSearch: _handleCitySearch,
                  placeholder: 'Search city...',
                  backgroundColor: AppColors.glassSurface,
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? WeatherErrorWidget(error: _error!, onRetry: _fetchInitialWeather)
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_currentEntry == null && _searchedEntry == null) {
      return const Center(child: Text('No weather data yet', style: TextStyle(color: Colors.white70)));
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_currentEntry != null) ...[
            _sectionTitle('Current Location'),
            const SizedBox(height: 12),
            _buildWeatherSection(_currentEntry!, _currentAdvisories.isEmpty ? const [] : _currentAdvisories),
            const SizedBox(height: 28),
          ],
          if (_isSearching)
            const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32), child: CircularProgressIndicator())),
          if (_searchError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_searchError!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
            ),
          if (_searchedEntry != null) ...[
            _sectionTitle('Searched City'),
            const SizedBox(height: 12),
            _buildWeatherSection(_searchedEntry!, _searchAdvisories),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildWeatherSection(_CityWeatherEntry entry, List<WeatherAdvisory> advisories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top display
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 6),
        //   child: WeatherDisplayWidget(weather: entry.weather),
        // ),
        // const SizedBox(height: 12),

        // Current weather
        CurrentWeatherWidget(weather: entry.weather),
        const SizedBox(height: 16),

        // Hourly
        if (entry.weather.hourlyForecasts.isNotEmpty) ...[
          HourlyForecastWidget(hourlyForecasts: entry.weather.hourlyForecasts, timezone: entry.weather.timezone ?? 'UTC'), // fallback if null
          const SizedBox(height: 12),
        ],

        // Daily
        DailyForecastWidget(weather: entry.weather),
        const SizedBox(height: 12),

        // Advisories list (glass cards)
        if (advisories.isNotEmpty) ...[
          Text('Smart tips', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Column(
            children: advisories.take(6).map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: WeatherAdvisoryCard(advisory: a),
            )).toList(),
          ),
        ],
      ],
    );
  }
}
