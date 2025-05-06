// utils/date_utils.dart
import 'package:intl/intl.dart';

class DateTimeUtils {
  // Format for time display (e.g., 6:30 AM)
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  // Format for date display (e.g., May 5, 2025)
  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  // Format for day of week (e.g., Monday)
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // Format for short month (e.g., May)
  static String formatMonth(DateTime date) {
    return DateFormat('MMM').format(date);
  }
  
  // Format for day number (e.g., 5)
  static String formatDay(DateTime date) {
    return DateFormat('d').format(date);
  }
  
  // Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  // Get a list of dates for a month
  static List<DateTime> getDaysInMonth(DateTime month) {
    // ignore: unused_local_variable
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    
    final dayCount = lastDay.day;
    final days = List<DateTime>.generate(
      dayCount,
      (index) => DateTime(month.year, month.month, index + 1),
    );
    
    return days;
  }
}