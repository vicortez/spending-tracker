import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/expense/expense.dart';
import 'package:spending_tracker/expense/expense_state.dart';

import 'edit_expense_page.dart';

class TableLineData {
  Expense? expense;
  Color backgroundColor;
  bool isAggregate;
  double? total;
  String catName;

  TableLineData(this.expense, this.backgroundColor, this.isAggregate, this.total, this.catName);
}

class SpendingReportPage extends StatelessWidget {
  const SpendingReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    var expenseState = context.watch<ExpenseState>();
    var expenses = expenseState.expenses;

    final SplayTreeMap<String, List<Expense>> orderedExpensesMap =
        SplayTreeMap<String, List<Expense>>((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    for (var expense in expenses) {
      orderedExpensesMap.putIfAbsent(expense.categoryName, () => <Expense>[]).add(expense);
    }

    // Quick and dirty way. Not scalable. Ideally we want a global object dictionary with theme name as keys.
    // or maybe there is a "fluttery" way to do it.
    bool isDarkMode = Theme.of(context).colorScheme.brightness == Brightness.dark;
    Color? tableBackground1 = Theme.of(context).colorScheme.background;
    Color? tableBackground2 = isDarkMode ? Colors.grey[850] : Colors.grey[300];

    List<TableLineData> tableLinesData = [];
    for (var expenseGroupEntry in orderedExpensesMap.entries) {
      String catName = expenseGroupEntry.key;
      List<Expense> groupExpenses = expenseGroupEntry.value;
      for (var expense in groupExpenses) {
        var backgroundColor = tableLinesData.length % 2 == 0 ? tableBackground1 : tableBackground2;
        tableLinesData.add(TableLineData(expense, backgroundColor!, false, null, catName));
      }
      var backgroundColor = tableLinesData.length % 2 == 0 ? tableBackground1 : tableBackground2;
      double total = groupExpenses.map((exp) => exp.amount).reduce((acc, element) => acc + element);
      tableLinesData.add(TableLineData(null, backgroundColor!, true, total, catName));
    }
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
                    for (var tableLine in tableLinesData)
                      TableRow(decoration: BoxDecoration(color: tableLine.backgroundColor), children: [
                        TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Text(
                              tableLine.catName,
                              style: TextStyle(
                                  fontWeight: tableLine.expense != null ? FontWeight.normal : FontWeight.bold),
                            )),
                        TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: tableLine.expense != null
                                ? Text(tableLine.expense!.date.toString().substring(0, 10))
                                : const Text(
                                    "Total: ",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  )),
                        TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: tableLine.expense != null
                                ? Text(tableLine.expense!.amount.toString())
                                : Text(tableLine.total.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                            height: tableLine.expense != null ? 30.0 : 40,
                            child: tableLine.expense != null
                                ? IconButton(
                                    padding: const EdgeInsets.all(0.0),
                                    icon: const Icon(Icons.edit_outlined, size: 18.0),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditExpensePage(
                                                  expense: tableLine.expense!,
                                                )),
                                      );
                                    },
                                  )
                                : const Text(""))
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
