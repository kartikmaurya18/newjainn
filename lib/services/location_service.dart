import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _cachedLocationKey = 'cached_location';
  static const String _cachedCityKey = 'cached_city';
  static const String _sunriseSunsetApiUrl =
      'https://api.sunrise-sunset.org/json?formatted=0'; // Base URL

  // Cache location data
  Future<void> cacheLocation(double latitude, double longitude, String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('${_cachedLocationKey}_lat', latitude);
      await prefs.setDouble('${_cachedLocationKey}_lng', longitude);
      await prefs.setString(_cachedCityKey, city);
    } catch (e) {
      debugPrint('Error caching location: $e');
    }
  }

  // Get cached location
  Future<Map<String, dynamic>?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('${_cachedLocationKey}_lat');
      final lng = prefs.getDouble('${_cachedLocationKey}_lng');
      final city = prefs.getString(_cachedCityKey);

      if (lat != null && lng != null && city != null) {
        return {'latitude': lat, 'longitude': lng, 'city': city};
      }
    } catch (e) {
      debugPrint('Error fetching cached location: $e');
    }
    return null;
  }

  // Get current location, either from cache or by fetching
  Future<Map<String, dynamic>> getCurrentLocation() async {
    // Check for cached location first
    final cachedLocation = await getCachedLocation();
    if (cachedLocation != null) {
      return cachedLocation;
    }

    // Request permission if not cached
    final permission = await _checkLocationPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }
    // Get current position 

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // Get address from coordinates
      
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final city = placemarks.first.locality ?? 'Unknown';

      // Cache the location
      await cacheLocation(position.latitude, position.longitude, city);
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'city': city,
      };
    } catch (e) {
      throw Exception('Error getting current location: $e');
    }
  }

  // Check and request location permission
  Future<LocationPermission> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  // Get sunrise and sunset times for a given location and date
  Future<Map<String, DateTime>> getSunriseSunset(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = '$_sunriseSunsetApiUrl&lat=$latitude&lng=$longitude&date=$formattedDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'];

          final sunrise = DateTime.parse(results['sunrise']).toLocal();
          final sunset = DateTime.parse(results['sunset']).toLocal();

          return {
            'sunrise': sunrise,
            'sunset': sunset,
          };
        }
      }

      throw Exception('Failed to fetch sunrise/sunset data');
    } catch (e) {
      debugPrint('Error fetching sunrise/sunset: $e');

      // Fallback to approximation if API fails
      final baseDate = DateTime(date.year, date.month, date.day);
      final sunrise = baseDate.add(const Duration(hours: 6)); // 6:00 AM
      final sunset = baseDate.add(const Duration(hours: 18)); // 6:00 PM
      return {'sunrise': sunrise, 'sunset': sunset};
    }
  }
}
