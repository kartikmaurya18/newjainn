class TithiModel {
  final int tithiNumber;
  final String tithiName;
  final String paksha; // Shukla (Bright) or Krishna (Dark)
  final bool isSpecial; // For special tithis like Ashtami, Chaturdashi, etc.

  TithiModel({
    required this.tithiNumber,
    required this.tithiName,
    required this.paksha,
    this.isSpecial = false,
  });

  // Tithi names in Sanskrit
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

  // Factory method to create tithi from date (simplified calculation for demo)
  // In a real app, this would use proper astronomical calculations
  factory TithiModel.fromDate(DateTime date) {
    // This is a simplified calculation for demonstration
    // A real implementation would use proper astronomical algorithms
    final int lunarDay = ((date.day + date.month) % 30) + 1;
    final bool isShukla = lunarDay <= 15;
    final int tithiNum = isShukla ? lunarDay : lunarDay - 15;
    
    String tithiName = tithiNames[tithiNum - 1];
    // Handle special case for 15th tithi
    if (tithiNum == 15) {
      tithiName = isShukla ? 'Purnima' : 'Amavasya';
    }
    
    // Some tithis are considered special in Jain tradition
    bool isSpecial = [8, 11, 14, 15].contains(tithiNum);
    
    return TithiModel(
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