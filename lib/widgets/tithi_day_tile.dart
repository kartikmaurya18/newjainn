import 'package:flutter/material.dart';
import '../../models/tithi_model.dart';

class TithiDayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final TithiModel? tithiModel;

  const TithiDayCell({
    Key? key,
    required this.date,
    required this.isSelected,
    required this.tithiModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tithiName = tithiModel?.tithi ?? '';
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.day.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tithiName,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white70 : Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
