import 'package:flutter/material.dart';
import 'package:jain_tithi_fixed/models/tithi_model.dart';
import 'package:jain_tithi_fixed/models/tithi_details_model.dart';
import 'package:jain_tithi_fixed/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TithiService {
  final LocationService _locationService = LocationService();
  static const String _tithiCacheKey = 'tithi_cache_';
  // static const Duration _cacheExpiration = Duration(hours: 24); // Currently unused

  Future<TithiModel> getTithiForDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_tithiCacheKey${date.year}_${date.month}_${date.day}';

      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final data = json.decode(cachedData);
        return TithiModel(
          date: date,
          tithi: data['tithiName'],
          isShubh: data['isSpecial'],
          sunrise: DateTime.parse(data['sunrise']),
          sunset: DateTime.parse(data['sunset']),
          tithiName: data['tithiName'],
          isSpecial: data['isSpecial'],
          tithiNumber: data['tithiNumber'],
          paksha: data['paksha'],
        );
      }

      final details = TithiDetailsModel.fromDate(date);
      final location = await _locationService.getCurrentLocation();
      final sunData = await _locationService.getSunriseSunset(
        location['latitude'],
        location['longitude'],
        date,
      );

      final sunrise = sunData['sunrise']!;
      final sunset = sunData['sunset']!;

      final tithi = TithiModel(
        tithi: details.tithiName,
        tithiName: details.tithiName,
        paksha: details.paksha,
        tithiNumber: details.tithiNumber,
        isShubh: details.isSpecial,
        isSpecial: details.isSpecial,
        date: date,
        sunrise: sunrise,
        sunset: sunset,
      );

      await prefs.setString(cacheKey, json.encode({
        'tithiName': tithi.tithi,
        'tithiNumber': tithi.tithiNumber,
        'paksha': tithi.paksha,
        'isSpecial': tithi.isShubh,
        'sunrise': tithi.sunrise.toIso8601String(),
        'sunset': tithi.sunset.toIso8601String(),
      }));

      return tithi;
    } catch (e) {
      debugPrint('Error getting tithi: $e');
      return TithiModel.empty(date);
    }
  }
  Future<Map<DateTime, TithiModel>> getTithisForMonth(DateTime month) async {
  final firstDayOfMonth = DateTime(month.year, month.month, 1);
  final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

  Map<DateTime, TithiModel> tithiMap = {};

  for (DateTime date = firstDayOfMonth;
      date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
      date = date.add(const Duration(days: 1))) {
    final tithi = await getTithiForDate(date);
    tithiMap[date] = tithi;
  }

  return tithiMap;
}


  Future<TithiDetailsModel> getTimingsForDate(DateTime date) async {
    try {
      final tithi = await getTithiForDate(date);
      return TithiDetailsModel.calculate(
        tithi.sunrise,
        tithi.sunset,
        tithi.tithi,
        tithiNumber: tithi.tithiNumber,
        tithiName: tithi.tithiName,
        paksha: tithi.paksha,
        isSpecial: tithi.isSpecial,
      );
    } catch (e) {
      debugPrint('Error getting timings: $e');

      final baseDate = DateTime(date.year, date.month, date.day);
      final sunrise = baseDate.add(const Duration(hours: 6));
      final sunset = baseDate.add(const Duration(hours: 18));

      final tithi = await getTithiForDate(date); // may return empty

      return TithiDetailsModel.calculate(
        sunrise,
        sunset,
        tithi.tithi,
        tithiNumber: tithi.tithiNumber,
        tithiName: tithi.tithiName,
        paksha: tithi.paksha,
        isSpecial: tithi.isSpecial,
      );
    }
  }
}
