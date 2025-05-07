import 'package:flutter/material.dart';
import 'package:jain_tithi_fixed/models/tithi_model.dart'; // This is the main model used for daily tithi
import 'package:jain_tithi_fixed/models/tithi_details_model.dart'; // Updated for details model
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
          date: date,
          tithi: data['tithiName'],
          isShubh: data['isSpecial'],
          sunrise: DateTime.parse(data['sunrise']),
          sunset: DateTime.parse(data['sunset']),
        );
      }

      // Calculate new tithi using TithiDetailsModel
      final details = TithiDetailsModel.fromDate(date);

      // Get sunrise/sunset
      final location = await _locationService.getCurrentLocation();
      final sunData = await _locationService.getSunriseSunset(
        location['latitude'],
        location['longitude'],
        date,
      );

      final sunrise = sunData['sunrise']!;
      final sunset = sunData['sunset']!;

      // Create TithiModel with new data
final tithi = TithiModel(
  tithiName: details.tithiName,
  paksha: details.paksha,
  tithiNumber: details.tithiNumber,
  isSpecial: details.isSpecial,
  date: date,
  sunrise: sunrise,
  sunset: sunset,
);


      // Cache the result
      await prefs.setString(cacheKey, json.encode({
        'tithiName': tithi.tithi,
        'isSpecial': tithi.isShubh,
        'sunrise': tithi.sunrise.toIso8601String(),
        'sunset': tithi.sunset.toIso8601String(),
      }));

      return tithi;
    } catch (e) {
      debugPrint('Error getting tithi: $e');
      return TithiModel.empty(date); // fallback
    }
  }

  // Get timings for a given date
  Future<TimingModel> getTimingsForDate(DateTime date) async {
    try {
      final tithi = await getTithiForDate(date);

      return TimingModel.calculate(
        tithi.sunrise,
        tithi.sunset,
        tithi.tithi,
      );
    } catch (e) {
      debugPrint('Error getting timings: $e');

      // Fallback if anything fails
      final baseDate = DateTime(date.year, date.month, date.day);
      final sunrise = baseDate.add(const Duration(hours: 6));
      final sunset = baseDate.add(const Duration(hours: 18));

      final tithi = await getTithiForDate(date);

      return TimingModel.calculate(
        sunrise,
        sunset,
        tithi.tithi,
      );
    }
  }

  // Get tithi and timing data for an entire month with caching
  Future<Map<DateTime, TithiModel>> getTithisForMonth(DateTime month) async {
    final Map<DateTime, TithiModel> tithis = {};
    final prefs = await SharedPreferences.getInstance();
    final monthCacheKey = '${_tithiCacheKey}month_${month.year}_${month.month}';

    try {
      final cachedData = prefs.getString(monthCacheKey);
      if (cachedData != null) {
        final data = json.decode(cachedData) as Map<String, dynamic>;
        for (var entry in data.entries) {
          final date = DateTime.parse(entry.key);
          final tithiData = entry.value as Map<String, dynamic>;
          tithis[date] = TithiModel(
            date: date,
            tithi: tithiData['tithiName'],
            isShubh: tithiData['isSpecial'],
            sunrise: DateTime.parse(tithiData['sunrise']),
            sunset: DateTime.parse(tithiData['sunset']),
          );
        }
        return tithis;
      }

      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(month.year, month.month, day);
        final tithi = await getTithiForDate(date);
        tithis[date] = tithi;
      }

      final cacheData = tithis.map((key, value) => MapEntry(
            key.toIso8601String(),
            {
              'tithiName': value.tithi,
              'isSpecial': value.isShubh,
              'sunrise': value.sunrise.toIso8601String(),
              'sunset': value.sunset.toIso8601String(),
            },
          ));

      await prefs.setString(monthCacheKey, json.encode(cacheData));

      return tithis;
    } catch (e) {
      debugPrint('Error getting month tithis: $e');
      return {};
    }
  }
}
