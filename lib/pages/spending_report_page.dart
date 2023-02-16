import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/expense/expense_state.dart';
import 'package:spending_tracker/pages/edit_expense_page.dart';

class SpendingReportPage extends StatelessWidget {
  const SpendingReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    var expenseState = context.watch<ExpenseState>();
    var expenses = expenseState.expenses;
    // expenses = expenses.sort()

    // Quick and dirty way. Not scalable. Ideally we want a global object dictionary with theme name as keys.
    // or maybe there is a "fluttery" way to do it.
    bool isDarkMode = Theme.of(context).colorScheme.brightness == Brightness.dark;
    var tableBackground1 = Theme.of(context).colorScheme.background;
    var tableBackground2 = isDarkMode ? Colors.grey[850] : Colors.grey[300];
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              SelectionArea(
                child: Table(
                  // border: const TableBorder(horizontalInside: BorderSide(color: Colors.white)),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1.5),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(0.5)
                  },
                  children: [
                    const TableRow(children: [
                      Text(
                        'Category',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '',
                      ),
                    ]),
                    for (var expenseEntry in expenses.asMap().entries)
                      TableRow(
                          decoration:
                              BoxDecoration(color: expenseEntry.key % 2 == 0 ? tableBackground1 : tableBackground2),
                          children: [
                            TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Text(expenseEntry.value.categoryName)),
                            TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Text(expenseEntry.value.date.toString().substring(0, 10))),
                            TableCell(
                                verticalAlignment: TableCellVerticalAlignment.middle,
                                child: Text(expenseEntry.value.amount.toString())),
                            SizedBox(
                                height: 30.0,
                                child: IconButton(
                                  padding: const EdgeInsets.all(0.0),
                                  icon: const Icon(Icons.edit_outlined, size: 18.0),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditExpensePage(
                                                expense: expenseEntry.value,
                                              )),
                                    );
                                  },
                                ))
                          ]),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
