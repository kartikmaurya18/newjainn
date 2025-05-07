// models/tithi_model.dart
class TithiModel {
  final String tithi;
  final bool isShubh; // Whether this is an auspicious day
  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;

  TithiModel({
    required this.tithi,
    required this.isShubh,
    required this.date,
    required this.sunrise,
    required this.sunset,
  });

  // Factory constructor to create a TithiModel from API response
  factory TithiModel.fromJson(Map<String, dynamic> json, DateTime date) {
    return TithiModel(
      tithi: json['tithi'] ?? 'Unknown',
      isShubh: json['isShubh'] ?? false,
      date: date,
      sunrise: DateTime.parse(json['sunrise']),
      sunset: DateTime.parse(json['sunset']),
    );
  }

  // For caching purposes
  Map<String, dynamic> toJson() {
    return {
      'tithi': tithi,
      'isShubh': isShubh,
      'date': date.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
    };
  }
}