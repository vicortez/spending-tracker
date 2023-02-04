import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/expense/expense_state.dart';

class SpendingReportPage extends StatelessWidget {
  const SpendingReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    var expenseState = context.watch<ExpenseState>();
    var expenses = expenseState.expenses;

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Table(
                border: const TableBorder(horizontalInside: BorderSide(color: Colors.white)),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1),
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
                  ]),
                  for (var expense in expenses)
                    TableRow(decoration: BoxDecoration(color: Colors.black), children: [
                      Text(expense.categoryName),
                      Text(expense.date.toString().substring(0, 10)),
                      Text(expense.amount.toString()),
                    ]),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
