// services/tithi_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages, unused_import
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tithi_model.dart';
import '../models/timming_model.dart';

class TithiService extends ChangeNotifier {
  final Map<String, TithiModel> _tithiCache = {};
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get a list of tithis for the given month
  Future<List<TithiModel>> getTithisForMonth(int year, int month, double latitude, double longitude) async {
    List<TithiModel> monthTithis = [];
    
    // Get number of days in the month
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateKey = _getDateKey(date, latitude, longitude);
      
      if (_tithiCache.containsKey(dateKey)) {
        monthTithis.add(_tithiCache[dateKey]!);
      } else {
        try {
          final tithi = await _fetchTithiForDate(date, latitude, longitude);
          _tithiCache[dateKey] = tithi;
          monthTithis.add(tithi);
        } catch (e) {
          // Use a placeholder for failed fetches
          monthTithis.add(_createPlaceholderTithi(date));
        }
      }
    }
    
    return monthTithis;
  }

  // Get tithi for specific date
  Future<TithiModel> getTithiForDate(DateTime date, double latitude, double longitude) async {
    final dateKey = _getDateKey(date, latitude, longitude);
    
    if (_tithiCache.containsKey(dateKey)) {
      return _tithiCache[dateKey]!;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final tithi = await _fetchTithiForDate(date, latitude, longitude);
      _tithiCache[dateKey] = tithi;
      _isLoading = false;
      notifyListeners();
      return tithi;
    } catch (e) {
      _errorMessage = 'Error fetching tithi data: $e';
      _isLoading = false;
      notifyListeners();
      return _createPlaceholderTithi(date);
    }
  }
  
  // Get timings based on a tithi
  TimingModel getTimingsFromTithi(TithiModel tithi) {
    return TimingModel.calculate(
      tithi.sunrise,
      tithi.sunset,
      tithi.name,
    );
  }

  // Generate a key for caching
  String _getDateKey(DateTime date, double latitude, double longitude) {
    return '${date.year}-${date.month}-${date.day}_${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';
  }

  // Fetch tithi data from API
  Future<TithiModel> _fetchTithiForDate(DateTime date, double latitude, double longitude) async {
    // First check cache in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _getDateKey(date, latitude, longitude);
    final cachedData = prefs.getString(cacheKey);
    
    if (cachedData != null) {
      final Map<String, dynamic> json = jsonDecode(cachedData);
      return TithiModel.fromJson(json, date);
    }
    
    // If not in cache, fetch from API
    // In a real app, this would call an actual API like Sunrise-Sunset API 
    // and a Tithi API like Drik Panchang
    // For this sample, we'll generate some mock data
    
    // Simulate API response time
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Generate mock sunrise/sunset times based on date and location
    final baseHour = (latitude / 10).round() % 6 + 5; // Between 5am and 11am
    final sunriseTime = DateTime(
      date.year, 
      date.month, 
      date.day, 
      baseHour, 
      ((longitude % 60) * 0.5).round()
    );
    
    final sunsetTime = DateTime(
      date.year, 
      date.month, 
      date.day, 
      baseHour + 12, 
      ((longitude % 60) * 0.5).round()
    );
    
    // Generate a mock tithi name based on the date
    final tithiDay = ((date.day + date.month) % 30) + 1;
    final paksha = tithiDay <= 15 ? 'Shukla' : 'Krishna';
    final tithiNum = tithiDay <= 15 ? tithiDay : tithiDay - 15;
    final tithiName = '$paksha ${_getTithiName(tithiNum)}';
    
    // Determine if it's an auspicious day (simplified logic for demo)
    final isShubh = date.weekday != DateTime.sunday && 
                    date.weekday != DateTime.tuesday &&
                    tithiNum != 4 &&
                    tithiNum != 9 &&
                    tithiNum != 14;
    
    final tithiData = {
      'tithi': tithiName,
      'isShubh': isShubh,
      'sunrise': sunriseTime.toIso8601String(),
      'sunset': sunsetTime.toIso8601String(),
    };
    
    // Cache this result
    await prefs.setString(cacheKey, jsonEncode(tithiData));
    
    return TithiModel.fromJson(tithiData, date);
  }
  
  // Create a placeholder tithi for failed API calls
  TithiModel _createPlaceholderTithi(DateTime date) {
    
    return TithiModel(
      name: 'Unknown',
      isShubh: false,
      date: date,
      sunrise: DateTime(date.year, date.month, date.day, 6, 0),
      sunset: DateTime(date.year, date.month, date.day, 18, 0),
    );
  }
  
  // Convert tithi number to name
  String _getTithiName(int tithiNum) {
    const tithiNames = [
      'Pratipada',   // 1
      'Dwitiya',     // 2
      'Tritiya',     // 3
      'Chaturthi',   // 4
      'Panchami',    // 5
      'Shashthi',    // 6
      'Saptami',     // 7
      'Ashtami',     // 8
      'Navami',      // 9
      'Dashami',     // 10
      'Ekadashi',    // 11
      'Dwadashi',    // 12
      'Trayodashi',  // 13
      'Chaturdashi', // 14
      'Purnima',     // 15 for Shukla
    ];
    
    if (tithiNum == 0 || tithiNum > 15) return 'Amavasya'; // 15 for Krishna
    return tithiNames[tithiNum - 1];
  }
  
  // Clear cache if it gets too large
  Future<void> clearOldCache() async {
    if (_tithiCache.length > 100) {
      final now = DateTime.now();
      final keysToRemove = _tithiCache.keys.where((key) {
        final parts = key.split('_');
        final dateParts = parts[0].split('-');
        final date = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
        
        // Remove items older than 30 days
        return now.difference(date).inDays > 30;
      }).toList();
      
      for (final key in keysToRemove) {
        _tithiCache.remove(key);
      }
      
      // Also clear SharedPreferences cache
      final prefs = await SharedPreferences.getInstance();
      for (final key in keysToRemove) {
        prefs.remove(key);
      }
    }
  }
}