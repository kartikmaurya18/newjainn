// ignore: unused_import
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
// ignore: unused_import
import '../models/tithi_model.dart';
// ignore: unused_import
import '../models/tithi_details_model.dart';
import 'package:jain_tithi_fixed/utils/sun_calculator.dart'; // custom util you'll create

class CsvParserService {
  Future<List<TithiDay>> loadTithiData() async {
    final csvString = await rootBundle.loadString('assets/data/tithi_data.csv');
    final List<List<dynamic>> csvData = CsvToListConverter().convert(csvString, eol: '\n');

    // Assuming headers in row 0
    final headers = csvData[0].map((e) => e.toString()).toList();
    final dataRows = csvData.sublist(1);

    return dataRows.map((row) {
      final map = Map.fromIterables(headers, row.map((e) => e.toString()));

      final date = DateTime.parse(map['date']);
      final lat = double.parse(map['latitude']);
      final lng = double.parse(map['longitude']);

      final sunrise = map['sunrise'] != ''
          ? DateTime.parse('${map['date']} ${map['sunrise']}')
          : SunCalculator.getSunrise(lat, lng, date);

      final sunset = map['sunset'] != ''
          ? DateTime.parse('${map['date']} ${map['sunset']}')
          : SunCalculator.getSunset(lat, lng, date);

      return TithiDay(
        date: date,
        tithiName: map['tithiName'],
        paksha: map['paksha'],
        month: map['month'],
        year: map['year'],
        details: TithiDetails(
          sunrise: sunrise,
          sunset: sunset,
          praharTimes: SunCalculator.calculatePrahar(sunrise, sunset),
        ),
      );
    }).toList();
  }
}
