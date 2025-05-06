import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:tithi_calendar/pages/calendar_page.dart';
import 'package:tithi_calendar/services/location_service.dart';
import 'package:tithi_calendar/services/tithi_service.dart';
import 'package:tithi_calendar/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Hive for local storage
    await Hive.initFlutter();
    await Hive.openBox('tithi_data');
    await Hive.openBox('app_settings');
  } catch (e) {
    // Optionally handle Hive initialization errors
    debugPrint('Hive initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => TithiService()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // Base size for responsiveness
        minTextAdapt: true,
        splitScreenMode: true,
builder: (_, __) => MaterialApp(
  title: 'Tithi Calendar',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme(),     // <-- Add parentheses if it's a method
  darkTheme: AppTheme.darkTheme(),  // <-- Same here
  themeMode: ThemeMode.system,
  home: const CalendarPage(),
),

      ),
    );
  }
}
