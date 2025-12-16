// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getCityName(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.locality}, ${place.administrativeArea ?? place.country}';
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  Future<CityCoordinates> getCoordinatesForCity(String cityName) async {
    try {
      final trimmedName = cityName.trim();
      if (trimmedName.isEmpty) {
        throw Exception('City name cannot be empty');
      }

      final locations = await locationFromAddress(trimmedName);
      if (locations.isEmpty) {
        throw Exception('No locations found for "$trimmedName"');
      }

      final location = locations.first;
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      String displayName = trimmedName;
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
          if ((place.administrativeArea ?? '').trim().isNotEmpty)
            place.administrativeArea!.trim(),
          if ((place.country ?? '').trim().isNotEmpty) place.country!.trim(),
        ];

        if (parts.isNotEmpty) {
          displayName = parts.join(', ');
        }
      }

      return CityCoordinates(
        latitude: location.latitude,
        longitude: location.longitude,
        displayName: displayName,
      );
    } catch (e) {
      print('LocationService getCoordinatesForCity error: $e');
      throw Exception('Could not find "$cityName". Please try another search.');
    }
  }
}

class CityCoordinates {
  final double latitude;
  final double longitude;
  final String displayName;

  const CityCoordinates({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });
}