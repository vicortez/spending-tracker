import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/common_widgets/my_button.dart';
import 'package:spending_tracker/config/config_name.dart';
import 'package:spending_tracker/config/config_state.dart';
import 'package:spending_tracker/models/expense/expense_state.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    var expenseState = context.watch<ExpenseState>();
    var configState = context.watch<ConfigState>();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text("See all months"),
                      value: configState.getConfig(ConfigName.seeAllMonths),
                      onChanged: (newValue) => configState.updateConfig(ConfigName.seeAllMonths, newValue),
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: "Delete all expenses",
                      onPressed: () {
                        expenseState.removeALl();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Expenses deleted')),
                        );
                      },
                      type: ButtonType.danger,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
