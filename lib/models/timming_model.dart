// models/tithi_details_model.dart

class TithiDetailsModel {
  final int tithiNumber;
  final String tithiName;
  final String paksha; // Shukla (Bright) or Krishna (Dark)
  final bool isSpecial; // For special tithis like Ashtami, Chaturdashi, etc.

  const TithiDetailsModel({
    required this.tithiNumber,
    required this.tithiName,
    required this.paksha,
    this.isSpecial = false,
  });

  /// Tithi names in Sanskrit
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
    'Purnima/Amavasya', // Will be either Purnima or Amavasya based on paksha
  ];

  /// Factory method to create TithiDetails from a date (simplified logic)
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
    return '$tithiName ($paksha Paksha)';
  }
}
