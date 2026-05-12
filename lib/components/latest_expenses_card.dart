import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/ui/card.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/router/navigation_extensions.dart';
import 'package:spending_tracker/router/route_utils.dart';
import 'package:spending_tracker/theme/app_theme.dart';
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                Text('Latest expenses', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () {
                    context.pushWithHistory(AppRouteConstants.allExpensesPath);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.grey[800],
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Padding(padding: EdgeInsets.only(left: 4), child: Text('See All')),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right, size: 16),
                      ],
                    ),
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
                  Colors.cyan.withValues(alpha: 0.2), // Transparent on left
                  Colors.cyan.withValues(alpha: 0.3), // Visible in middle
                  Colors.cyan.withValues(alpha: 0.2), // Transparent on right
                ],
                stops: const [0.0, 0.5, 1.0], // Left, center, right
              ),
            ),
          ),
          // Content section - expense list
          if (latestExpenses.isEmpty)
            const Padding(padding: EdgeInsets.all(16.0), child: Text('No expenses yet'))
          else
            ...latestExpenses.asMap().entries.map((entry) {
              final index = entry.key;
              final expense = entry.value;
              final category = categoryProvider.categories.firstWhere(
                (cat) => cat.id == expense.categoryId,
                orElse: () => categoryProvider.categories.first,
              );

              return _buildExpenseItem(context, expense, category.name, index, isDarkMode);
            }),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(
    BuildContext context,
    ExpenseEntity expense,
    String categoryName,
    int index,
    bool isDarkMode,
  ) {
    final dateStr = expense.date.toString().substring(0, 10);
    final createdAtStr = expense.createdAt.toString().substring(0, 10);
    final amountStr = toMaxDecimalPlacesOmitTrailingZeroes(expense.amount, 2);

    // Split amount into integer and decimal parts for different styling
    final parts = amountStr.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    final isEven = index % 2 == 0;
    final backgroundColor = isDarkMode
        ? (isEven ? Colors.black : AppTheme.veryDarkGrey)
        : (isEven ? Colors.white : Colors.grey[200]);

    return InkWell(
      onTap: () {
        context.pushWithHistory('/reports/edit/${expense.id}');
      },
      splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      highlightColor: Colors.grey.withValues(alpha: 0.05),
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left part: category and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoryName, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr · $createdAtStr',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: '.$decimalPart',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
