import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/expenses_table.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_filter.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';

class ListExpensesPage extends StatelessWidget {
  const ListExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final domainProvider = context.watch<DomainProvider>();

    final filter = ExpenseFilter(
      sortBy: [
        SortCriteria(field: SortField.domainName, order: SortOrder.ascending),
        SortCriteria(field: SortField.categoryName, order: SortOrder.ascending),
        SortCriteria(field: SortField.expenseDate, order: SortOrder.descending),
      ],
    );

    final filteredExpenses = filterExpenses(
      expenses: expenseProvider.expenses,
      filter: filter,
      categories: categoryProvider.categories,
      domains: domainProvider.domains,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('All expenses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Click an expense to manage it',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: ExpensesTable(
              expenses: filteredExpenses,
              categories: categoryProvider.categories,
              domains: domainProvider.domains,
            ),
          ),
        ],
      ),
    );
  }
}
