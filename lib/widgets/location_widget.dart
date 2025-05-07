import 'package:flutter/material.dart';
import 'package:jain_tithi_fixed/services/location_service.dart';
import 'package:jain_tithi_fixed/themes/app_theme.dart';

class LocationWidget extends StatefulWidget {
  final Function(Map<String, dynamic>)? onLocationChanged;

  const LocationWidget({
    super.key,
    this.onLocationChanged,
  });

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  final LocationService _locationService = LocationService();
  bool _isLoading = true;
  String _locationName = 'Loading location...';

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? location = await _locationService.getCachedLocation();

      // If no cached location, fetch current location
      location ??= await _locationService.getCurrentLocation();

      final city = location['city'] ?? 'Unknown location';

      setState(() {
        _locationName = city;
        _isLoading = false;
      });

      widget.onLocationChanged?.call(location);
    } catch (e) {
      debugPrint('Error fetching location: $e');
      setState(() {
        _locationName = 'Location unavailable';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                )
              : Text(
                  _locationName,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _isLoading ? null : _loadLocation,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.refresh,
                color: _isLoading ? Colors.grey : AppTheme.secondaryColor,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
