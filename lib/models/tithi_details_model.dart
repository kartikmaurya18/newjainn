class TithiDetailsModel {
  final int tithiNumber;
  final String tithiName;
  final String paksha; // Shukla or Krishna
  final bool isSpecial;

  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? navkarshi;
  final DateTime? sadhPorsi;
  final DateTime? porsi;
  final DateTime? purimaddha;
  final DateTime? avaddha;

  const TithiDetailsModel({
    required this.tithiNumber,
    required this.tithiName,
    required this.paksha,
    this.isSpecial = false,
    this.sunrise,
    this.sunset,
    this.navkarshi,
    this.sadhPorsi,
    this.porsi,
    this.purimaddha,
    this.avaddha,
  });

  static final List<String> tithiNames = [
    'Pratipada',
    'Dwitiya',
    'Tritiya',
    'Chaturthi',
    'Panchami',
    'Shashti',
    'Saptami',
    'Ashtami',
    'Navami',
    'Dashami',
    'Ekadashi',
    'Dwadashi',
    'Trayodashi',
    'Chaturdashi',
    'Purnima/Amavasya',
  ];

  /// Factory method to estimate tithi from date only
  factory TithiDetailsModel.fromDate(DateTime date) {
    final int lunarDay = ((date.day + date.month) % 30) + 1;
    final bool isShukla = lunarDay <= 15;
    final int tithiNum = isShukla ? lunarDay : lunarDay - 15;

    String tithiName = tithiNames[tithiNum - 1];
    if (tithiNum == 15) {
      tithiName = isShukla ? 'Purnima' : 'Amavasya';
    }

    final isSpecial = [8, 11, 14, 15].contains(tithiNum);

    return TithiDetailsModel(
      tithiNumber: tithiNum,
      tithiName: tithiName,
      paksha: isShukla ? 'Shukla' : 'Krishna',
      isSpecial: isSpecial,
    );
  }

  /// Calculates all ritual times using sunrise and sunset
  static TithiDetailsModel calculate({
    required DateTime sunrise,
    required DateTime sunset,
    required int tithiNumber,
    required String tithiName,
    required String paksha,
    bool isSpecial = false,
  }) {
    final prahar = Duration(
      milliseconds: ((sunset.difference(sunrise).inMilliseconds) / 4).round(),
    );

    return TithiDetailsModel(
      tithiNumber: tithiNumber,
      tithiName: tithiName,
      paksha: paksha,
      isSpecial: isSpecial,
      sunrise: sunrise,
      sunset: sunset,
      navkarshi: sunrise.add(const Duration(minutes: 48)),
      porsi: sunrise.add(prahar),
      sadhPorsi: sunrise.add(prahar ~/ 2),
      purimaddha: sunrise.add(prahar * 2),
      avaddha: sunrise.add(prahar * 3),
    );
  }

  @override
  String toString() => '$tithiName ($paksha Paksha)';
}
