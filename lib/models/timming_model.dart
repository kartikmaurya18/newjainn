// models/timing_model.dart
class TimingModel {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime navkarshi;
  final DateTime porsi;
  final DateTime sadhPorsi;
  final DateTime purimaddha;
  final DateTime avaddha;
  final String tithi;

  TimingModel({
    required this.sunrise,
    required this.sunset,
    required this.navkarshi,
    required this.porsi,
    required this.sadhPorsi,
    required this.purimaddha,
    required this.avaddha,
    required this.tithi,
  });

  // Factory method to calculate all timings based on sunrise/sunset
  factory TimingModel.calculate(DateTime sunrise, DateTime sunset, String tithi) {
    // Calculate the total daytime duration
    final int daytimeMinutes = sunset.difference(sunrise).inMinutes;
    
    // Each prahar is 1/4 of total daytime
    final int praharMinutes = daytimeMinutes ~/ 4;
    
    // Navkarshi is 48 minutes after sunrise
    final navkarshi = sunrise.add(const Duration(minutes: 48));
    
    // Porsi is first prahar after sunrise
    final porsi = sunrise.add(Duration(minutes: praharMinutes));
    
    // Sadh Porsi is 1.5 prahars after sunrise
    final sadhPorsi = sunrise.add(Duration(minutes: (praharMinutes * 1.5).round()));
    
    // Purimaddha is midday (halfway between sunrise and sunset)
    final purimaddha = sunrise.add(Duration(minutes: daytimeMinutes ~/ 2));
    
    // Avaddha is in the last quarter of the day
    final avaddha = sunrise.add(Duration(minutes: daytimeMinutes - (daytimeMinutes ~/ 4)));

    return TimingModel(
      sunrise: sunrise,
      sunset: sunset,
      navkarshi: navkarshi,
      porsi: porsi,
      sadhPorsi: sadhPorsi,
      purimaddha: purimaddha,
      avaddha: avaddha,
      tithi: tithi,
    );
  }
}