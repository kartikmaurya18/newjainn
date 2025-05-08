import 'package:flutter/material.dart';
import 'package:jain_tithi_fixed/models/tithi_model.dart';
import 'package:jain_tithi_fixed/models/tithi_details_model.dart';
import 'package:jain_tithi_fixed/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TithiService {
  final LocationService _locationService = LocationService();
  static const String _tithiCacheKey = 'tithi_cache_';
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  var TimingModel;

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
            tithiName: tithiData['tithiName'],
            paksha: tithiData['paksha'],
            tithiNumber: tithiData['tithiNumber'],
            isSpecial: tithiData['isSpecial'],
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
              'tithiNumber': value.tithiNumber,
              'paksha': value.paksha,
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
