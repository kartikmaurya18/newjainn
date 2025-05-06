// pages/day_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tithi_model.dart';
import '../models/timming_model.dart';
import '../services/tithi_service.dart';
import '../themes/app_theme.dart';
import '../utils/date_utils.dart';
import '../utils/responsive_utils.dart';

class DayDetailPage extends StatefulWidget {
  final DateTime date;
  final TithiModel tithi;

  const DayDetailPage({
    super.key,
    required this.date,
    required this.tithi,
  });

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> {
  late TimingModel _timings;
  
  @override
  void initState() {
    super.initState();
    final tithiService = Provider.of<TithiService>(context, listen: false);
    _timings = tithiService.getTimingsFromTithi(widget.tithi);
  }
  
  @override
  Widget build(BuildContext context) {
    final isShubhDin = widget.tithi.isShubh;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(DateTimeUtils.formatDate(widget.date)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _buildPortraitLayout(context, isShubhDin)
                : _buildLandscapeLayout(context, isShubhDin);
          },
        ),
      ),
    );
  }
  
  Widget _buildPortraitLayout(BuildContext context, bool isShubhDin) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.value(
          context,
          mobile: 16,
          tablet: 24,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(context),
            const SizedBox(height: 24),
            _buildTithiCard(context, isShubhDin),
            const SizedBox(height: 16),
            _buildSunTimesCard(context),
            const SizedBox(height: 16),
            _buildTimingsCard(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLandscapeLayout(BuildContext context, bool isShubhDin) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.value(
          context,
          mobile: 16,
          tablet: 24,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(context),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildTithiCard(context, isShubhDin),
                      const SizedBox(height: 16),
                      _buildSunTimesCard(context),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildTimingsCard(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDateHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateTimeUtils.formatDayOfWeek(widget.date),
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, base: 18),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          DateTimeUtils.formatDate(widget.date),
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, base: 24),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTithiCard(BuildContext context, bool isShubhDin) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isShubhDin ? AppTheme.shubhColor : AppTheme.ashubhColor,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.value(
          context,
          mobile: 16,
          tablet: 24,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Tithi Details',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, base: 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isShubhDin 
                        ? AppTheme.shubhColor.withOpacity(0.2)
                        : AppTheme.ashubhColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isShubhDin ? 'Shubh Din' : 'Ashubh Din',
                    style: TextStyle(
                      color: isShubhDin 
                          ? AppTheme.shubhColor
                          : AppTheme.ashubhColor,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.fontSize(context, base: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context, 
              'Tithi', 
              widget.tithi.name,
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSunTimesCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.value(
          context,
          mobile: 16,
          tablet: 24,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sun Timings',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, base: 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSunTimeItem(
                    context,
                    'Sunrise',
                    DateTimeUtils.formatTime(widget.tithi.sunrise),
                    Icons.wb_sunny,
                    AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSunTimeItem(
                    context,
                    'Sunset',
                    DateTimeUtils.formatTime(widget.tithi.sunset),
                    Icons.wb_twilight,
                    AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSunTimeItem(BuildContext context, String label, 
                          String time, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: ResponsiveUtils.value(context, mobile: 32, tablet: 48),
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, base: 14),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, base: 16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimingsCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.value(
          context,
          mobile: 16,
          tablet: 24,
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timings',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, base: 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context, 
              'Navkarshi', 
              DateTimeUtils.formatTime(_timings.navkarshi),
              Icons.free_breakfast,
            ),
            _buildInfoRow(
              context, 
              'Porsi', 
              DateTimeUtils.formatTime(_timings.porsi),
              Icons.access_time,
            ),
            _buildInfoRow(
              context, 
              'Sadh Porsi', 
              DateTimeUtils.formatTime(_timings.sadhPorsi),
              Icons.hourglass_empty,
            ),
            _buildInfoRow(
              context, 
              'Purimaddha', 
              DateTimeUtils.formatTime(_timings.purimaddha),
              Icons.wb_sunny_outlined,
            ),
            _buildInfoRow(
              context, 
              'Avaddha', 
              DateTimeUtils.formatTime(_timings.avaddha),
              Icons.nights_stay_outlined,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, 
                      String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: ResponsiveUtils.value(context, mobile: 20, tablet: 24),
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, base: 14),
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, base: 16),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}