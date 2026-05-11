import 'package:flutter/material.dart';
import 'package:spending_tracker/components/latest_expenses_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: LatestExpensesCard(),
        ),
      ],
    );
  }
}
