// models/tithi_model.dart

class TithiModel {
  final String tithi;
  final bool isShubh;
  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;

const TithiModel({
  required this.tithi,
  required this.isShubh,
  required this.date,
  required this.sunrise,
  required this.sunset,
});



  /// Factory method to create a TithiModel from JSON (e.g., API or cache)
  factory TithiModel.fromJson(Map<String, dynamic> json) {
    return TithiModel(
      tithi: json['tithi'] ?? 'Unknown',
      isShubh: json['isShubh'] ?? false,
      date: DateTime.parse(json['date']),
      sunrise: DateTime.parse(json['sunrise']),
      sunset: DateTime.parse(json['sunset']),
    );
  }

  /// For saving to SharedPreferences or sending via API
  Map<String, dynamic> toJson() {
    return {
      'tithi': tithi,
      'isShubh': isShubh,
      'date': date.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
    };
  }

  /// Returns an empty model (useful for fallbacks)
  static TithiModel empty(DateTime date) {
    return TithiModel(
      tithi: 'Unknown',
      isShubh: false,
      date: date,
      sunrise: date.add(const Duration(hours: 6)),
      sunset: date.add(const Duration(hours: 18)),
    );
  }
}
