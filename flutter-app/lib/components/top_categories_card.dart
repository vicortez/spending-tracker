import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/ui/card.dart';
import 'package:spending_tracker/components/ui/sectioned_bar_chart.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/focused_month/focused_month_provider.dart';
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
    final focusedMonthProvider = context.watch<FocusedMonthProvider>();

    final focusedMonth = focusedMonthProvider.getMonth();
    final filteredExpensesForMonth = expenseProvider.expenses.where((e) {
      return e.date.year == focusedMonth.year && e.date.month == focusedMonth.month;
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
            // Header section
            Container(
              width: double.infinity,
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Top categories this month', style: Theme.of(context).textTheme.titleMedium),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
            // Divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.cyan.withValues(alpha: 0.2),
                    Colors.cyan.withValues(alpha: 0.3),
                    Colors.cyan.withValues(alpha: 0.2),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  SectionedBarChart(data: summary.topCategories, totalAmount: summary.totalAmount),
                  const SizedBox(height: 12),
                  if (summary.topCategories.isEmpty)
                    const Text('No data for this month')
                  else
                    ...summary.topCategories.map((item) => _buildLegendItem(context, item)),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        toMaxDecimalPlacesOmitTrailingZeroes(summary.totalAmount, 2),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.categoryName,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            toMaxDecimalPlacesOmitTrailingZeroes(item.totalAmount, 2),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
