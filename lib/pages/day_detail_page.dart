import 'package:flutter/material.dart';
import 'package:jain_tithi_fixed/models/tithi_details_model.dart';
import 'package:jain_tithi_fixed/models/tithi_model.dart';
import 'package:jain_tithi_fixed/services/tithi_service.dart';
import 'package:jain_tithi_fixed/themes/app_theme.dart';
import 'package:jain_tithi_fixed/utils/date_utils.dart';

class DayDetailPage extends StatefulWidget {
  final DateTime date;

  const DayDetailPage({
    super.key,
    required this.date,
  });

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> with SingleTickerProviderStateMixin {
  final TithiService _tithiService = TithiService();

  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  TithiModel? _tithi;
  TithiDetailsModel? _timing;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tithi = await _tithiService.getTithiForDate(widget.date);
      final timing = await _tithiService.getTimingsForDate(widget.date);

      if (!mounted) return;

      setState(() {
        _tithi = tithi;
        _timing = timing;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          DateUtil.formatFullDate(widget.date),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF3F51B5),
                Color(0xFF303F9F),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -10,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Refresh data',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppTheme.errorColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationCard(),
              const SizedBox(height: 20),
              _buildTithiCard(),
              const SizedBox(height: 20),
              _buildTimingsCard(),
              const SizedBox(height: 20),
              _buildTimelineCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return const Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(Icons.location_on),
        title: Text('Your Location'),
        subtitle: Text('Using current device location or selected city'),
      ),
    );
  }

  Widget _buildTithiCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tithi Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Tithi: ${_tithi?.tithiName ?? 'Unknown'}'),
            Text('Paksha: ${_tithi?.paksha ?? '-'}'),
            Text('Month: ${_tithi?.month ?? '-'}'),
            Text('Year: ${_tithi?.year ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sunrise & Sunset',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Sunrise: ${_timing?.sunrise ?? '-'}'),
            Text('Sunset: ${_timing?.sunset ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ritual Timings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Navkarshi: ${_timing?.navkarshi ?? '-'}'),
            Text('Porsi: ${_timing?.porsi ?? '-'}'),
            Text('Sadh Porsi: ${_timing?.sadhPorsi ?? '-'}'),
            Text('Purimaddha: ${_timing?.purimaddha ?? '-'}'),
            Text('Avaddha: ${_timing?.avaddha ?? '-'}'),
          ],
        ),
      ),
    );
  }
}
