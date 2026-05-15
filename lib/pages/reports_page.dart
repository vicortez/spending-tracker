import 'package:flutter/material.dart';
import 'package:spending_tracker/components/latest_expenses_card.dart';
import 'package:spending_tracker/components/top_categories_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(width: double.infinity, child: LatestExpensesCard()),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: TopCategoriesCard()),
        ],
      ),
    );
  }
}
