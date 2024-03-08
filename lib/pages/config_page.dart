import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/common_widgets/my_button.dart';
import 'package:spending_tracker/config/config_name.dart';
import 'package:spending_tracker/config/config_state.dart';
import 'package:spending_tracker/models/category/category.dart';
import 'package:spending_tracker/models/category/category_state.dart';
import 'package:spending_tracker/models/domain/domain.dart';
import 'package:spending_tracker/models/domain/domain_state.dart';
import 'package:spending_tracker/models/expense/expense.dart';
import 'package:spending_tracker/models/expense/expense_state.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    var expenseState = context.watch<ExpenseState>();
    var domainState = context.watch<DomainState>();
    var categoryState = context.watch<CategoryState>();
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
                    const SizedBox(height: 15),
                    MyButton(
                      text: "Export all app data",
                      onPressed: kIsWeb ? null : () => onPressedExportAction(configState, context),
                      type: ButtonType.normal,
                    ),
                    if (kIsWeb)
                      const Text(
                        "Exporting is currently unavailable for web",
                        style: TextStyle(fontSize: 12),
                      ),
                    const SizedBox(height: 15),
                    MyButton(
                      text: "Import app data",
                      onPressed: kIsWeb
                          ? null
                          : () {
                              showConfirmDialog(
                                  context,
                                  () =>
                                      handleImportFile(context, configState, categoryState, expenseState, domainState),
                                  () => {},
                                  "Confirm",
                                  "Importing app data will erase any current app data, and load the new one.");
                            },
                      type: ButtonType.normal,
                    ),
                    if (kIsWeb)
                      const Text(
                        "Importing is currently unavailable for web",
                        style: TextStyle(fontSize: 12),
                      ),
                    const SizedBox(height: 30),
                    MyButton(
                      text: "Delete all expenses".toUpperCase(),
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

  void onPressedExportAction(ConfigState configState, BuildContext context) {
    Map<String, dynamic> jsonAppData = configState.getAllAppPersistedData();
    String fileName = configState.getExportDataFilename();
    configState
        .saveJsonToFile(jsonAppData, fileName)
        .then((res) => handleToastFileExportResult(res, context, fileName));
  }

  void handleToastFileExportResult(bool res, BuildContext context, String fileName) {
    if (res) {
      String topLevelFolderName = Platform.isAndroid ? "Android/data" : "Download";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File exported to $topLevelFolderName folder as $fileName")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error exporting file :(')),
      );
    }
  }

  void showConfirmDialog(
      BuildContext context, VoidCallback onConfirm, VoidCallback onCancel, String title, String body) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
        onCancel();
      },
    );
    Widget continueButton = TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary.withOpacity(0.05)),
      ),
      child: const Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop();
        onConfirm();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void handleImportFile(BuildContext context, ConfigState configState, CategoryState categoryState,
      ExpenseState expenseState, DomainState domainState) async {
    Map<String, dynamic>? jsonData = await configState.importJsonDataFile();
    if (jsonData != null) {
      categoryState.setDataFromImport(jsonData[Category.PERSIST_NAME]);
      expenseState.setDataFromImport(jsonData[Expense.PERSIST_NAME]);
      domainState.setDataFromImport(jsonData[Domain.PERSIST_NAME]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data imported"), duration: Duration(seconds: 2)),
      );
    }
    return;
  }
}
