import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/edit_expense_form.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';

class EditExpensePage extends StatelessWidget {
  const EditExpensePage({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context) {
    var expenseProvider = context.watch<ExpenseProvider>();
    int? id = int.tryParse(expenseId);

    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit expense')),
        body: const Center(
          child: Text('Invalid expense ID'),
        ),
      );
    }

    ExpenseEntity? expense = expenseProvider.getById(id);

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit expense')),
        body: const Center(
          child: Text('Expense not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit expense')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: EditExpenseForm(expense: expense),
            ),
          );
        },
      ),
    );
  }
}
