class TithiModel {
  final String tithiName;
  final bool isSpecial;
  final int tithiNumber;
  final String paksha;
  final bool isShubh;
  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;
  final String? month;
  final String? year;

  TithiModel({
    required this.tithiName,
    required this.isSpecial,
    required this.tithiNumber,
    required this.paksha,
    required this.isShubh,
    required this.date,
    required this.sunrise,
    required this.sunset,
    this.month,
    this.year,
  });

  factory TithiModel.fromJson(Map<String, dynamic> json) {
    return TithiModel(
      tithiName: json['tithiName'] ?? 'Unknown',
      isSpecial: json['isSpecial'] ?? false,
      tithiNumber: json['tithiNumber'] ?? 0,
      paksha: json['paksha'] ?? 'Unknown',
      isShubh: json['isShubh'] ?? false,
      date: DateTime.parse(json['date']),
      sunrise: DateTime.parse(json['sunrise']),
      sunset: DateTime.parse(json['sunset']),
      month: json['month'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tithiName': tithiName,
      'isSpecial': isSpecial,
      'tithiNumber': tithiNumber,
      'paksha': paksha,
      'isShubh': isShubh,
      'date': date.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'sunset': sunset.toIso8601String(),
      'month': month,
      'year': year,
    };
  }

  static TithiModel empty(DateTime date) {
    return TithiModel(
      tithiName: 'Unknown',
      isSpecial: false,
      tithiNumber: 0,
      paksha: 'Unknown',
      isShubh: false,
      date: date,
      sunrise: date.add(const Duration(hours: 6)),
      sunset: date.add(const Duration(hours: 18)),
      month: null,
      year: null,
    );
  }
}
