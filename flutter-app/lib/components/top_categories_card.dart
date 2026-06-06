import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/ui/card.dart';
import 'package:spending_tracker/components/ui/sectioned_bar_chart.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/router/navigation_extensions.dart';
import 'package:spending_tracker/router/route_utils.dart';
import 'package:spending_tracker/utils/number_utils.dart';
import 'package:spending_tracker/utils/spending_utils.dart';

class TopCategoriesCard extends StatelessWidget {
  const TopCategoriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final now = DateTime.now();
    final filteredExpensesForMonth = expenseProvider.expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();

    final summary = getTopCategoriesSpending(
      expenses: filteredExpensesForMonth,
      categories: categoryProvider.categories,
      limit: 5,
    );

    return InkWell(
      onTap: () {
        context.pushWithHistory(AppRouteConstants.topCategoriesPath);
      },
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Top categories this month', style: Theme.of(context).textTheme.titleMedium),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            Container(
              height: 2,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SectionedBarChart(
                    data: summary.topCategories,
                    totalAmount: summary.totalAmount,
                    height: 16,
                  ),
                  const SizedBox(height: 16),
                  if (summary.topCategories.isEmpty)
                    const Text('No data for this month')
                  else
                    ...summary.topCategories.map((item) => _buildLegendItem(context, item)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        toMaxDecimalPlacesOmitTrailingZeroes(summary.totalAmount, 2),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, CategorySpending item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.categoryName,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            toMaxDecimalPlacesOmitTrailingZeroes(item.totalAmount, 2),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
