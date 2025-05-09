import 'package:flutter/material.dart';
import 'package:jain_tithi_fixed/pages/calendar_page.dart';
import 'package:jain_tithi_fixed/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JainCalendarApp());
}

class JainCalendarApp extends StatelessWidget {
  const JainCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jain Tithi Calendar',
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      home: const CalendarPage(),
    );
  }
}
