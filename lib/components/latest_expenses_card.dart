import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/ui/card.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/router/navigation_extensions.dart';
import 'package:spending_tracker/utils/number_utils.dart';

class LatestExpensesCard extends StatelessWidget {
  const LatestExpensesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    // Get latest 5 expenses (sorted by date descending)
    final expenses = [...expenseProvider.expenses];
    expenses.sort((a, b) => b.date.compareTo(a.date));
    final latestExpenses = expenses.take(5).toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest expenses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to all expenses page
                  },
                  icon: const Text('See All'),
                  label: const Icon(Icons.chevron_right, size: 16),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    backgroundColor: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          // Divider between header and content
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.withOpacity(0.3),
                  Colors.cyan.withOpacity(0.1),
                ],
              ),
            ),
          ),
          // Content section - expense list
          if (latestExpenses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No expenses yet'),
            )
          else
            ...latestExpenses.asMap().entries.map((entry) {
              final index = entry.key;
              final expense = entry.value;
              final category = categoryProvider.categories.firstWhere(
                (cat) => cat.id == expense.categoryId,
                orElse: () => categoryProvider.categories.first,
              );

              return Column(
                children: [
                  _buildExpenseItem(context, expense, category.name),
                  // Divider between items (except after last item)
                  if (index < latestExpenses.length - 1)
                    Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(BuildContext context, ExpenseEntity expense, String categoryName) {
    final dateStr = expense.date.toString().substring(0, 10);
    final amountStr = toMaxDecimalPlacesOmitTrailingZeroes(expense.amount, 2);

    // Split amount into integer and decimal parts for different styling
    final parts = amountStr.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    return InkWell(
      onTap: () {
        context.pushWithHistory('/reports/edit/${expense.id}');
      },
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left part: category and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
            // Right part: amount and chevron
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: integerPart,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      TextSpan(
                        text: '.$decimalPart',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
