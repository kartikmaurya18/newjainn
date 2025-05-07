// lib/models/tithi_details_model.dart

class TithiDetailsModel {
  final String tithiName;
  final String paksha;
  final int tithiNumber;
  final bool isSpecial;

  TithiDetailsModel({
    required this.tithiName,
    required this.paksha,
    required this.tithiNumber,
    required this.isSpecial,
  });

  // This is a placeholder logic; replace with actual calculation if needed
  static TithiDetailsModel fromDate(DateTime date) {
    final day = date.day;
    final paksha = day <= 15 ? 'Shukla' : 'Krishna';
    final tithiNumber = day <= 15 ? day : day - 15;
    final tithiName = 'Tithi $tithiNumber';
    final isSpecial = [5, 10, 15].contains(tithiNumber); // Example special logic

    return TithiDetailsModel(
      tithiName: tithiName,
      paksha: paksha,
      tithiNumber: tithiNumber,
      isSpecial: isSpecial,
    );
  }
}
