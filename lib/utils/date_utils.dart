import 'package:intl/intl.dart';

class DateUtil {
  // Format date as "Month DD, YYYY"
  static String formatFullDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }
  
  // Format date as "Month DD"
  static String formatMonthDay(DateTime date) {
    return DateFormat('MMMM dd').format(date);
  }
  
  // Format time as "HH:MM AM/PM"
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
  
  // Format time with seconds as "HH:MM:SS AM/PM"
  static String formatTimeWithSeconds(DateTime time) {
    return DateFormat('hh:mm:ss a').format(time);
  }
  
  // Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  // Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  // Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
  
  // Get readable duration (e.g., "2 hours 30 minutes")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'} '
             '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }
  }
  
  // Calculate prahar (time division) based on sunrise and sunset
  static List<DateTime> calculatePrahars(DateTime sunrise, DateTime sunset) {
    final daytimeMinutes = sunset.difference(sunrise).inMinutes;
    final praharMinutes = daytimeMinutes ~/ 4;
    
    return [
      sunrise,
      sunrise.add(Duration(minutes: praharMinutes)),
      sunrise.add(Duration(minutes: praharMinutes * 2)),
      sunrise.add(Duration(minutes: praharMinutes * 3)),
      sunset,
    ];
  }
}
