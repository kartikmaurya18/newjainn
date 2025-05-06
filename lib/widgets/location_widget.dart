// widgets/location_widget.dart
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../utils/responsive_utils.dart';

class LocationWidget extends StatelessWidget {
  final LocationService locationService;
  final VoidCallback onRefresh;

  const LocationWidget({
    super.key,
    required this.locationService,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(ResponsiveUtils.value(
        context,
        mobile: 8,
        tablet: 16,
      )),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.value(
          context,
          mobile: 12,
          tablet: 16,
        )),
        child: Row(
          children: [
            const Icon(Icons.location_on, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, base: 12),
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (locationService.isLoading)
                    const Text('Detecting location...')
                  else if (locationService.errorMessage != null)
                    Text(
                      locationService.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    )
                  else if (locationService.currentLocation != null)
                    Text(
                      locationService.currentLocation!.cityName,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, base: 16),
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Text('Location not available'),
                  
                  if (locationService.currentLocation != null)
                    Text(
                      '${locationService.currentLocation!.latitude.toStringAsFixed(4)}, ${locationService.currentLocation!.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, base: 12),
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: locationService.isLoading ? null : onRefresh,
              tooltip: 'Refresh location',
            ),
          ],
        ),
      ),
    );
  }
}