import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/filter_bottom_sheet_content.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/components/ui/my_bottom_sheet.dart';
import 'package:spending_tracker/components/ui/sectioned_bar_chart.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_filter.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/focused_month/focused_month_provider.dart';
import 'package:spending_tracker/utils/number_utils.dart';
import 'package:spending_tracker/utils/spending_utils.dart';

class TopCategoriesPage extends StatefulWidget {
  const TopCategoriesPage({super.key});

  @override
  State<TopCategoriesPage> createState() => _TopCategoriesPageState();
}

class _TopCategoriesPageState extends State<TopCategoriesPage> {
  ExpenseFilter? _filter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filter == null) {
      final focusedMonth = context.read<FocusedMonthProvider>().getMonth();
      _filter = ExpenseFilter(year: focusedMonth.year, month: focusedMonth.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    context.watch<DomainProvider>(); // Ensure rebuild on domain changes if needed

    final filter = _filter!;

    final filteredExpenses = filterExpenses(
      expenses: expenseProvider.expenses,
      filter: filter,
      categories: categoryProvider.categories,
      domains: [],
    );

    final summary = getTopCategoriesSpending(
      expenses: filteredExpenses,
      categories: categoryProvider.categories,
      limit: 20,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Top Categories')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CoolButton(
                text: 'Filter',
                icon: Icons.filter_list,
                onPressed: () => _showFilterBottomSheet(context, categoryProvider.categories),
              ),
              const SizedBox(height: 24),
              Text(_getFilterDescription(), style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              SectionedBarChart(
                data: summary.topCategories,
                totalAmount: summary.totalAmount,
                height: 32.0,
              ),
              const SizedBox(height: 32),
              if (summary.topCategories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No data for selected filter'),
                  ),
                )
              else
                ...summary.topCategories.map(
                  (item) => _buildDetailItem(context, item, summary.totalAmount),
                ),
              const Divider(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    toMaxDecimalPlacesOmitTrailingZeroes(summary.totalAmount, 2),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterDescription() {
    final filter = _filter!;
    if (filter.expenseDateRange != null) {
      final range = filter.expenseDateRange!;
      String start = range.start?.toString().substring(0, 10) ?? 'Beginning';
      String end = range.end?.toString().substring(0, 10) ?? 'End';
      return 'Spending from $start to $end';
    }
    if (filter.year != null) {
      String desc = 'Spending for ${filter.year}';
      if (filter.month != null) {
        desc += '-${filter.month.toString().padLeft(2, '0')}';
        if (filter.day != null) {
          desc += '-${filter.day.toString().padLeft(2, '0')}';
        }
      }
      return desc;
    }
    return 'All-time Spending';
  }

  void _showFilterBottomSheet(BuildContext context, List<dynamic> categories) {
    showMyBottomSheet(
      context: context,
      title: 'Filter Report',
      content: FilterBottomSheetContent(
        currentFilter: _filter!,
        categories: categories.cast(),
        onFilterChanged: (newFilter) {
          setState(() {
            _filter = newFilter;
          });
        },
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, CategorySpending item, double totalAmount) {
    final percentage = (item.totalAmount / totalAmount * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.categoryName, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '$percentage% of total',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            toMaxDecimalPlacesOmitTrailingZeroes(item.totalAmount, 2),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
