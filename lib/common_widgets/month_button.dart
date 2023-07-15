import 'package:flutter/material.dart';
import 'package:spending_tracker/models/month_names.dart';

class MonthButton extends StatelessWidget {
  final int month;
  final bool allMonths;
  final VoidCallback onPressed;

  const MonthButton({super.key, required this.month, required this.allMonths, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    String monthAbbrev = monthNames[month ?? 1]!.substring(0, 3).toUpperCase();
    return FloatingActionButton(
      onPressed: () => allMonths ? null : onPressed(),
      disabledElevation: 0,
      backgroundColor: allMonths ? Colors.grey : Theme.of(context).colorScheme.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month_outlined),
          const SizedBox(height: 2),
          Text(allMonths ? "ALL" : monthAbbrev),
        ],
      ),
    );
  }
}
