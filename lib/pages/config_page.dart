import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/common_widgets/my_button.dart';
import 'package:spending_tracker/expense/expense_state.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    var expenseState = context.watch<ExpenseState>();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(10),
                child: MyButton(
                  text: "Delete all expenses",
                  onPressed: () {
                    expenseState.removeALl();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expenses deleted')),
                    );
                  },
                  type: ButtonType.danger,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
