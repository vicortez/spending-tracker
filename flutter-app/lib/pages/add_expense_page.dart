import 'package:flutter/material.dart';
import 'package:spending_tracker/components/edit_expense_form.dart';

class AddExpensePage extends StatelessWidget {
  const AddExpensePage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.date,
  });

  final int categoryId;
  final String categoryName;
  final String amount;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: EditExpenseForm(
                expense: null,
                initialCategoryId: categoryId,
                initialCategoryName: categoryName,
                initialAmount: amount,
                initialDate: date,
              ),
            ),
          );
        },
      ),
    );
  }
}
