// pages/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/tithi_model.dart';
import '../services/location_service.dart';
import '../services/tithi_service.dart';
import '../utils/date_utils.dart';
import '../utils/responsive_utils.dart';
import '../widgets/tithi_day_tile.dart';
import '../widgets/location_widget.dart';
import 'day_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<TithiModel> _monthTithis = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    await locationService.init();
    if (locationService.currentLocation != null) {
      _loadMonthData();
    }
  }

  Future<void> _loadMonthData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final locationService = Provider.of<LocationService>(context, listen: false);
      final tithiService = Provider.of<TithiService>(context, listen: false);
      
      if (locationService.currentLocation != null) {
        final tithis = await tithiService.getTithisForMonth(
          _focusedDay.year,
          _focusedDay.month,
          locationService.currentLocation!.latitude,
          locationService.currentLocation!.longitude,
        );
        
        if (mounted) {
          setState(() {
            _monthTithis = tithis;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading calendar data: $e')),
        );
      }
    }
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
    
    // Find tithi for the selected day
    final selectedTithi = _monthTithis.firstWhere(
      (tithi) => DateTimeUtils.isSameDay(tithi.date, selectedDay),
      orElse: () => _createPlaceholderTithi(selectedDay),
    );
    
    // Navigate to details page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayDetailPage(
          date: selectedDay,
          tithi: selectedTithi,
        ),
      ),
    );
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _focusedDay = newMonth;
    });
    _loadMonthData();
  }

  void _refreshLocation() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    await locationService.getCurrentLocation();
    _loadMonthData();
  }

  TithiModel _createPlaceholderTithi(DateTime date) {
    return TithiModel(
      name: 'Unknown',
      isShubh: false,
      date: date,
      sunrise: DateTime(date.year, date.month, date.day, 6, 0),
      sunset: DateTime(date.year, date.month, date.day, 18, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jain Calendar'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark 
                ? Icons.light_mode 
                : Icons.dark_mode),
            onPressed: () {
              // This would be implemented with a theme provider in a complete app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme toggle would be implemented here')),
              );
            },
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: Column(
        children: [
          // Location widget
          Consumer<LocationService>(
            builder: (context, locationService, child) {
              return LocationWidget(
                locationService: locationService,
                onRefresh: _refreshLocation,
              );
            },
          ),
          
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final previousMonth = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                      1,
                    );
                    _onMonthChanged(previousMonth);
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, base: 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final nextMonth = DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                      1,
                    );
                    _onMonthChanged(nextMonth);
                  },
                ),
              ],
            ),
          ),
          
          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: _buildWeekdayHeaders(context),
            ),
          ),
          
          // Calendar grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : locationService.currentLocation == null
                    ? const Center(child: Text('Please enable location to view calendar'))
                    : _buildCalendarGrid(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeekdayHeaders(BuildContext context) {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return List.generate(7, (index) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            weekdays[index],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.fontSize(context, base: 14),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCalendarGrid(BuildContext context) {
    // Get all dates in the month
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    
    // Calculate padding days to start the month on the correct weekday
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 is Sunday in our grid
    final paddingDays = List.generate(startWeekday, (index) {
      final day = firstDayOfMonth.subtract(Duration(days: startWeekday - index));
      return day;
    });
    
    // All days to display (padding + month days)
    final allDays = [
      ...paddingDays,
      ...List.generate(daysInMonth, (index) => 
        DateTime(_focusedDay.year, _focusedDay.month, index + 1)
      ),
    ];
    
    // Calculate total rows needed
    final totalDays = allDays.length;
    final rowCount = (totalDays / 7).ceil();
    
    // Add padding to complete the last row if needed
    final remainingDays = rowCount * 7 - totalDays;
    if (remainingDays > 0) {
      final lastDay = allDays.last;
      allDays.addAll(
        List.generate(remainingDays, (index) => 
          lastDay.add(Duration(days: index + 1))
        )
      );
    }
    
    // Build calendar grid
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
      ),
      itemCount: allDays.length,
      itemBuilder: (context, index) {
        final day = allDays[index];
        final isCurrentMonth = day.month == _focusedDay.month;
        
        // Find tithi for this day if we have it
        TithiModel? dayTithi;
        if (isCurrentMonth) {
          try {
            dayTithi = _monthTithis.firstWhere(
              (tithi) => DateTimeUtils.isSameDay(tithi.date, day),
              orElse: () => throw Exception('Tithi not found'),
            );
          } catch (_) {
            // If we don't have tithi data, leave it null
          }
        }
        
        final isToday = DateTimeUtils.isSameDay(day, DateTime.now());
        final isSelected = _selectedDay != null && 
                          DateTimeUtils.isSameDay(day, _selectedDay!);
        
        return Opacity(
          opacity: isCurrentMonth ? 1.0 : 0.3,
          child: TithiDayTile(
            date: day,
            tithiData: dayTithi,
            isSelected: isSelected,
            isToday: isToday,
            onTap: isCurrentMonth ? () => _onDaySelected(day) : () {},
          ),
        );
      },
    );
  }
}