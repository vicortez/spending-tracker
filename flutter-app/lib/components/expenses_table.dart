import 'package:flutter/material.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/router/navigation_extensions.dart';
import 'package:spending_tracker/theme/app_theme.dart';

class ExpensesTable extends StatelessWidget {
  const ExpensesTable({
    super.key,
    required this.expenses,
    required this.categories,
    required this.domains,
  });

  final List<ExpenseEntity> expenses;
  final List<CategoryEntity> categories;
  final List<DomainEntity> domains;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses found'));
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Table Header
        Container(
          color: isDarkMode ? Colors.teal : Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'Category',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Date',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Amount',
                  textAlign: TextAlign.end,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // Table Content
        Expanded(
          child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final category = categories.firstWhere(
                (c) => c.id == expense.categoryId,
                orElse: () => CategoryEntity(id: -1, name: 'Unknown', enabled: true),
              );
              final domain = domains.firstWhere(
                (d) => d.id == category.domainId,
                orElse: () => DomainEntity(id: -1, name: 'Unknown'),
              );

              final isEven = index % 2 == 0;
              final backgroundColor = isDarkMode
                  ? (isEven ? Colors.black : AppTheme.veryDarkGrey)
                  : (isEven ? Colors.white : Colors.grey[200]);

              // Amount formatting: 2 fixed decimals
              final amountStr = expense.amount.toStringAsFixed(2);
              final parts = amountStr.split('.');
              final integerPart = parts[0];
              final decimalPart = parts[1];

              return InkWell(
                onTap: () {
                  context.pushWithHistory('/reports/edit/${expense.id}');
                },
                child: Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: Row(
                    spacing: 4,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              domain.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.date.toString().substring(0, 10),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Created: ${expense.createdAt.toString().substring(0, 10)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: RichText(
                          textAlign: TextAlign.end,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            children: [
                              TextSpan(text: integerPart),
                              TextSpan(
                                text: '.$decimalPart',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
