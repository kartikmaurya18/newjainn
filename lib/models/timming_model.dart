class TithiDetailsModel {
  final int tithiNumber;
  final String tithiName;
  final String paksha; // 'Shukla' or 'Krishna'
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

  static const List<String> tithiNames = [
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
    'Purnima/Amavasya', // 15th Tithi
  ];

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

  @override
  String toString() {
    return '$tithiName (${paksha} Paksha)';
  }
}
