// widgets/tithi_day_tile.dart
import 'package:flutter/material.dart';
import '../models/tithi_model.dart';
import '../themes/app_theme.dart';
import '../utils/date_utils.dart';
import '../utils/responsive_utils.dart';

class TithiDayTile extends StatelessWidget {
  final DateTime date;
  final TithiModel? tithiData;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const TithiDayTile({
    super.key,
    required this.date,
    this.tithiData,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isThisMonth = date.month == DateTime.now().month;
    final Color textColor = isThisMonth 
        ? Theme.of(context).textTheme.bodyMedium!.color!
        : Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.2)
              : isToday 
                  ? AppTheme.todayHighlight.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday 
              ? Border.all(color: AppTheme.todayHighlight, width: 2)
              : null,
        ),
        margin: EdgeInsets.all(ResponsiveUtils.value(
          context, 
          mobile: 2, 
          tablet: 4,
        )),
        padding: EdgeInsets.all(ResponsiveUtils.value(
          context, 
          mobile: 4, 
          tablet: 8,
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            Text(
              DateTimeUtils.formatDay(date),
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, base: 16),
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? AppTheme.primaryColor
                    : textColor,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Tithi name if available
            if (tithiData != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: tithiData!.isShubh 
                      ? AppTheme.shubhColor.withOpacity(0.2)
                      : AppTheme.ashubhColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FittedBox(
                  child: Text(
                    tithiData!.name.split(' ').last, // Only show tithi name, not paksha
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, base: 10),
                      color: tithiData!.isShubh 
                          ? AppTheme.shubhColor
                          : AppTheme.ashubhColor,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}