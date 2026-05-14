import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/expenses_table.dart';
import 'package:spending_tracker/components/filter_bottom_sheet_content.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/components/ui/my_bottom_sheet.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_filter.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';

class ListExpensesPage extends StatefulWidget {
  const ListExpensesPage({super.key});

  @override
  State<ListExpensesPage> createState() => _ListExpensesPageState();
}

class _ListExpensesPageState extends State<ListExpensesPage> {
  late ExpenseFilter _filter;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _filter = ExpenseFilter(
      year: now.year,
      month: now.month,
      sortBy: [
        SortCriteria(field: SortField.domainName, order: SortOrder.ascending),
        SortCriteria(field: SortField.categoryName, order: SortOrder.ascending),
        SortCriteria(field: SortField.expenseDate, order: SortOrder.descending),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final domainProvider = context.watch<DomainProvider>();

    final filteredExpenses = filterExpenses(
      expenses: expenseProvider.expenses,
      filter: _filter,
      categories: categoryProvider.categories,
      domains: domainProvider.domains,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('All expenses')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: CoolButton(
                    text: 'Filter',
                    onPressed: () => _showFilterBottomSheet(context, categoryProvider.categories),
                    icon: Icons.filter_list,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CoolButton(
                    text: 'Sort',
                    onPressed: () => _showSortBottomSheet(context),
                    icon: Icons.sort,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
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

  void _showFilterBottomSheet(BuildContext context, List<dynamic> categories) {
    showMyBottomSheet(
      context: context,
      title: 'Filter Expenses',
      content: FilterBottomSheetContent(
        currentFilter: _filter,
        categories: categories.cast(),
        onFilterChanged: (newFilter) {
          setState(() {
            _filter = newFilter;
          });
        },
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showMyBottomSheet(
      context: context,
      title: 'Sort Expenses',
      content: const SizedBox(height: 100, child: Center(child: Text('Sort controls coming soon'))),
    );
  }
}
