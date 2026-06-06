import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/month_names.dart';
import 'package:spending_tracker/router/navigation_extensions.dart';
import 'package:spending_tracker/utils/color_utils.dart';
import 'package:spending_tracker/utils/number_utils.dart';

class OldSpendingReportPage extends StatelessWidget {
  const OldSpendingReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    var expenseProvider = context.watch<ExpenseProvider>();
    var categoryProvider = context.watch<CategoryProvider>();

    DateTime month = DateTime.now();
    List<ExpenseEntity> expenses = [...expenseProvider.expenses];
    List<CategoryEntity> categories = [...categoryProvider.categories];
    expenses.sort((a, b) => a.date.compareTo(b.date));
    expenses = expenses
        .where((expense) => expense.date.year == month.year && expense.date.month == month.month)
        .toList();

    // Quick and dirty way. Not scalable. Ideally we want a global object dictionary with theme name as keys.
    // or maybe there is a "fluttery" way to do it.
    bool isDarkMode = Theme.of(context).colorScheme.brightness == Brightness.dark;
    Color? tableBackground1 = Theme.of(context).colorScheme.surface;
    Color? tableBackground2 = isDarkMode
        ? lighten(Theme.of(context).colorScheme.surface, 5)
        : darken(Theme.of(context).colorScheme.surface, 5);

    double totalSpentCurrentMonth = expenses.fold(0, (sum, expense) => sum + expense.amount);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Spending Report (Experimental)'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Showing report for ${monthNames[month.month]}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total spent: \$${toMaxDecimalPlacesOmitTrailingZeroes(totalSpentCurrentMonth, 2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(3),
                3: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.grey.withValues(alpha: 0.3)),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...expenses.asMap().entries.map((entry) {
                  int index = entry.key;
                  ExpenseEntity expense = entry.value;
                  CategoryEntity? category = categories.firstWhere(
                    (cat) => cat.id == expense.categoryId,
                    orElse: () => CategoryEntity(id: -1, name: 'Unknown', enabled: true),
                  );

                  return TableRow(
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? tableBackground1 : tableBackground2,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(expense.id.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(expense.date.toString().substring(0, 10)),
                      ),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(category.name)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('\$${toMaxDecimalPlacesOmitTrailingZeroes(expense.amount, 2)}'),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Detailed list view (experimental)"),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final category = categories.firstWhere(
                  (cat) => cat.id == expense.categoryId,
                  orElse: () => CategoryEntity(id: -1, name: 'Unknown', enabled: true),
                );

                return ListTile(
                  title: Text(category.name),
                  subtitle: Text(expense.date.toString().substring(0, 16)),
                  trailing: Text('\$${toMaxDecimalPlacesOmitTrailingZeroes(expense.amount, 2)}'),
                  onTap: () {
                    // Navigate to edit page
                    context.pushWithHistory('/reports/edit/${expense.id}');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
