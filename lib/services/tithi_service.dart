import 'package:flutter/material.dart';
import 'package:jain_tithi_fixed/models/timming_model.dart';
import 'package:jain_tithi_fixed/models/tithi_model.dart';
import 'package:jain_tithi_fixed/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TithiService {
  final LocationService _locationService = LocationService();
  static const String _tithiCacheKey = 'tithi_cache_';
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  // Get tithi for a given date with caching
  Future<TithiModel> getTithiForDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_tithiCacheKey${date.year}_${date.month}_${date.day}';
      
      // Check cache
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final data = json.decode(cachedData);
        return TithiModel(
          tithiNumber: data['tithiNumber'],
          tithiName: data['tithiName'],
          paksha: data['paksha'],
          isSpecial: data['isSpecial'],
        );
      }

      // Calculate new tithi
      final tithi = TithiModel.fromDate(date);
      
      // Cache the result
      await prefs.setString(cacheKey, json.encode({
        'tithiNumber': tithi.tithiNumber,
        'tithiName': tithi.tithiName,
        'paksha': tithi.paksha,
        'isSpecial': tithi.isSpecial,
      }));
      
      return tithi;
    } catch (e) {
      debugPrint('Error getting tithi: $e');
      // Return a default tithi in case of error
      return const TithiModel(
        tithiNumber: 1,
        tithiName: 'Unknown',
        paksha: 'Shukla',
        isSpecial: false,
      );
    }
  }
  
  // Get timings for a given date with improved error handling
  Future<TimingModel> getTimingsForDate(DateTime date) async {
    try {
      // Get the user's location
      final location = await _locationService.getCurrentLocation();
      
      // Get sunrise and sunset times for the location and date
      final sunData = await _locationService.getSunriseSunset(
        location['latitude'],
        location['longitude'],
        date,
      );
      
      // Get tithi for the date
      final tithi = await getTithiForDate(date);
      
      // Calculate all timings based on sunrise and sunset
      return TimingModel.calculate(
        sunData['sunrise']!,
        sunData['sunset']!,
        tithi.toString(),
      );
    } catch (e) {
      debugPrint('Error getting timings: $e');
      // Fallback to approximation if any step fails
      final baseDate = DateTime(date.year, date.month, date.day);
      final sunrise = baseDate.add(const Duration(hours: 6)); // 6:00 AM
      final sunset = baseDate.add(const Duration(hours: 18)); // 6:00 PM
      
      final tithi = await getTithiForDate(date);
      
      return TimingModel.calculate(
        sunrise,
        sunset,
        tithi.toString(),
      );
    }
  }
  
  // Get tithi and timing data for an entire month with caching
  Future<Map<DateTime, TithiModel>> getTithisForMonth(DateTime month) async {
    final Map<DateTime, TithiModel> tithis = {};
    final prefs = await SharedPreferences.getInstance();
    final monthCacheKey = '${_tithiCacheKey}month_${month.year}_${month.month}';
    
    try {
      // Check cache first
      final cachedData = prefs.getString(monthCacheKey);
      if (cachedData != null) {
        final data = json.decode(cachedData) as Map<String, dynamic>;
        for (var entry in data.entries) {
          final date = DateTime.parse(entry.key);
          final tithiData = entry.value as Map<String, dynamic>;
          tithis[date] = TithiModel(
            tithiNumber: tithiData['tithiNumber'],
            tithiName: tithiData['tithiName'],
            paksha: tithiData['paksha'],
            isSpecial: tithiData['isSpecial'],
          );
        }
        return tithis;
      }

      // Calculate tithis for the month
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(month.year, month.month, day);
        final tithi = await getTithiForDate(date);
        tithis[date] = tithi;
      }
      
      // Cache the results
      final cacheData = tithis.map((key, value) => MapEntry(
        key.toIso8601String(),
        {
          'tithiNumber': value.tithiNumber,
          'tithiName': value.tithiName,
          'paksha': value.paksha,
          'isSpecial': value.isSpecial,
        },
      ));
      
      await prefs.setString(monthCacheKey, json.encode(cacheData));
      
      return tithis;
    } catch (e) {
      debugPrint('Error getting month tithis: $e');
      // Return empty map in case of error
      return {};
    }
  }
}
