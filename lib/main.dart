import 'package:flutter/material.dart';
import 'package:jain_tithi_fixed/pages/calendar_page.dart';
import 'package:jain_tithi_fixed/themes/app_theme.dart';

void main() {
  runApp(const JainCalendarApp());
}

class JainCalendarApp extends StatelessWidget {
  const JainCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Jain Calendar',
      theme: AppTheme.lightTheme, // Must be ThemeData
      debugShowCheckedModeBanner: false,
      home: CalendarPage(),
    );
  }
}
