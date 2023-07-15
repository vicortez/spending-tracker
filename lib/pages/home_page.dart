import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/models/category/category_state.dart';
import 'package:spending_tracker/common_widgets/my_button.dart';
import 'package:spending_tracker/models/expense/expense_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final expenseAmountTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var categoryState = context.watch<CategoryState>();
    var categories = categoryState.getEnabledCategories();
    categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Center(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (BuildContext ctx, int index) => const SizedBox(
                height: 10,
              ),
              itemBuilder: (BuildContext ctx, int index) => MyButton(
                onPressed: () {
                  handleSubmitExpense(categories[index].name, expenseAmountTextController);
                },
                text: categories[index].name,
              ),
            ),
          ),
          TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: '💸 Register expense'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              controller: expenseAmountTextController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.-]+')),
              ]),
        ],
      ),
    );
  }

  void handleSubmitExpense(String categoryName, TextEditingController expenseAmountTextController) {
    double? amount = double.tryParse(expenseAmountTextController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid expense'),
        ),
      );
    } else {
      var expenseState = context.read<ExpenseState>();
      expenseState.addExpense(categoryName, amount);
      expenseAmountTextController.clear();
    }
  }
}
