// services/location_service.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String cityName;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });

  @override
  String toString() => cityName;
}

class LocationService extends ChangeNotifier {
  LocationData? _currentLocation;
  bool _isLoading = false;
  String? _errorMessage;

  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize location service
  Future<void> init() async {
    try {
      await getCurrentLocation();
    } catch (e) {
      _errorMessage = 'Could not initialize location service';
      notifyListeners();
    }
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location services are disabled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permissions are denied';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permissions are permanently denied';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      
      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      String cityName = 'Unknown Location';
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        cityName = place.locality ?? place.subAdministrativeArea ?? 'Unknown Location';
      }
      
      _currentLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error getting location: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set location manually
  void setLocation(double latitude, double longitude, String cityName) {
    _currentLocation = LocationData(
      latitude: latitude,
      longitude: longitude,
      cityName: cityName,
    );
    notifyListeners();
  }
}