class SunCalculator {
  static DateTime getSunrise(double lat, double lng, DateTime date) {
    // Use package or implement your logic here
    // For now just mock
    return DateTime(date.year, date.month, date.day, 6, 30);
  }

  static DateTime getSunset(double lat, double lng, DateTime date) {
    return DateTime(date.year, date.month, date.day, 18, 30);
  }

  static List<Map<String, DateTime>> calculatePrahar(DateTime sunrise, DateTime sunset) {
    final totalDayDuration = sunset.difference(sunrise);
    final praharDuration = totalDayDuration ~/ 4;

    return List.generate(4, (i) {
      final start = sunrise.add(praharDuration * i);
      final end = start.add(praharDuration);
      return {'start': start, 'end': end};
    });
  }
}
