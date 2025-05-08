import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
// In calendar_page.dart

import 'package:jain_tithi_fixed/models/tithi_model.dart';
import 'package:jain_tithi_fixed/services/tithi_service.dart';
import 'package:jain_tithi_fixed/themes/app_theme.dart';
import 'package:jain_tithi_fixed/utils/date_utils.dart' as date_util;
import 'package:jain_tithi_fixed/widgets/location_widget.dart';
import 'package:jain_tithi_fixed/pages/day_detail_page.dart';

class CalendarPage extends StatefulWidget {
   const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with SingleTickerProviderStateMixin {
  final TithiService _tithiService = TithiService();

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, TithiModel> _tithis = {};
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _loadMonthData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMonthData() async {
    setState(() => _isLoading = true);
    final tithis = await _tithiService.getTithisForMonth(_focusedDay);
    setState(() {
      _tithis = tithis;
      _isLoading = false;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => DayDetailPage(date: selectedDay),
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() => _focusedDay = focusedDay);
    _loadMonthData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jain Calendar'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _isLoading ? _buildLoader() : _buildCalendarContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date_util.DateUtil.formatMonthDay(_selectedDay),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            LocationWidget(onLocationChanged: (_) => _loadMonthData()),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
  }

  Widget _buildCalendarContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCalendar(),
          const SizedBox(height: 20),
          _buildLegendCard(),
          const SizedBox(height: 20),
          _buildTodayButton(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => date_util.DateUtil.isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          onPageChanged: _onPageChanged,
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: AppTheme.accentColor, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: _buildDayTile,
            selectedBuilder: (context, day, focusedDay) => _buildDayTile(context, day, focusedDay, isSelected: true),
            todayBuilder: (context, day, focusedDay) => _buildDayTile(context, day, focusedDay, isToday: true),
          ),
        ),
      ),
    );
  }

  Widget _buildDayTile(BuildContext context, DateTime day, DateTime focusedDay, {bool isSelected = false, bool isToday = false}) {
    final tithi = _tithis.entries.firstWhere(
      (entry) => date_util.DateUtil.isSameDay(entry.key, day),
      orElse: () => MapEntry(day, TithiModel.empty()),
    ).value;

    return TithiDayTile(
      date: day,
      tithi: tithi,
      isSelected: isSelected,
      isToday: isToday,
      onTap: () => _onDaySelected(day, focusedDay),
    );
  }

  Widget _buildLegendCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calendar Legend', style: AppTheme.headingSmall),
            const SizedBox(height: 12),
            _buildLegendItem(color: AppTheme.primaryColor, text: 'Selected Day'),
            _buildLegendItem(color: AppTheme.accentColor, text: 'Today'),
            _buildLegendItem(color: Colors.white, borderColor: Colors.black26, text: 'Purnima (Full Moon)'),
            _buildLegendItem(color: Colors.black87, text: 'Amavasya (New Moon)', textColor: Colors.white),
            _buildLegendItem(color: AppTheme.secondaryColor.withOpacity(0.3), text: 'Special Tithi (Ashtami, Ekadashi, etc.)'),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _selectedDay = DateTime.now();
          _focusedDay = DateTime.now();
        });
        _loadMonthData();
      },
      icon: const Icon(Icons.today),
      label: const Text('Today'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, Color? borderColor, required String text, Color textColor = AppTheme.textPrimary}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(text, style: AppTheme.bodyMedium.copyWith(color: textColor)),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Jain Calendar'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This app shows important ritual timings according to Jain traditions.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Text('Timings shown:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Text('• Sunrise & Sunset'),
              Text('• Navkarshi (48 minutes after sunrise)'),
              Text('• Porsi (End of first prahar)'),
              Text('• Sadh Porsi (1.5 prahars after sunrise)'),
              Text('• Purimaddha (Midday)'),
              Text('• Avaddha (Beginning of last quarter)'),
              SizedBox(height: 16),
              Text('Tap on any day to see detailed timings.', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
