import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/config/config_name.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/focused_month/focused_month_provider.dart';
import 'package:spending_tracker/utils/sheet_exporter.dart';
import 'package:spending_tracker/utils/toast_utils.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var expenseProvider = context.watch<ExpenseProvider>();
    var domainProvider = context.watch<DomainProvider>();
    var categoryProvider = context.watch<CategoryProvider>();
    var configProvider = context.watch<ConfigProvider>();
    var focusedMonthProvider = context.watch<FocusedMonthProvider>();

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
                      title: const Text('See all months'),
                      value: configProvider.getConfig(ConfigName.seeAllMonths),
                      onChanged: (newValue) =>
                          configProvider.updateConfig(ConfigName.seeAllMonths, newValue),
                    ),
                    const SizedBox(height: 15),
                    CoolButton(
                      text: 'Export to sheet (excel)',
                      onPressed: kIsWeb
                          ? null
                          : () => onPressedExportToSheetAction(
                              domainProvider,
                              categoryProvider,
                              expenseProvider,
                              configProvider,
                              focusedMonthProvider,
                              context,
                            ),
                      type: ButtonType.normal,
                    ),
                    if (kIsWeb)
                      const Text(
                        'Exporting is currently unavailable for web',
                        style: TextStyle(fontSize: 12),
                      ),
                    const SizedBox(height: 15),
                    CoolButton(
                      text: 'Export all app data',
                      onPressed: kIsWeb
                          ? null
                          : () => onPressedExportAction(configProvider, context),
                      type: ButtonType.normal,
                    ),
                    if (kIsWeb)
                      const Text(
                        'Exporting is currently unavailable for web',
                        style: TextStyle(fontSize: 12),
                      ),
                    const SizedBox(height: 15),
                    CoolButton(
                      text: 'Import app data',
                      onPressed: kIsWeb
                          ? null
                          : () {
                              showConfirmDialog(
                                context,
                                () => handleImportFile(
                                  context,
                                  configProvider,
                                  categoryProvider,
                                  expenseProvider,
                                  domainProvider,
                                ),
                                () => {},
                                'Confirm',
                                'Importing app data will erase any current app data, and load the new one.',
                              );
                            },
                      type: ButtonType.normal,
                    ),
                    if (kIsWeb)
                      const Text(
                        'Importing is currently unavailable for web',
                        style: TextStyle(fontSize: 12),
                      ),
                    const SizedBox(height: 30),
                    CoolButton(
                      text: 'Delete all expenses'.toUpperCase(),
                      onPressed: () {
                        expenseProvider.removeALl();
                        showToast(context, 'Expenses deleted');
                      },
                      type: ButtonType.danger,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void onPressedExportToSheetAction(
    DomainProvider domainProvider,
    CategoryProvider categoryProvider,
    ExpenseProvider expenseProvider,
    ConfigProvider configProvider,
    FocusedMonthProvider focusedMonthProvider,
    BuildContext context,
  ) async {
    try {
      List<DomainEntity> domains = [...domainProvider.domains];
      List<CategoryEntity> categories = [...categoryProvider.categories];
      List<ExpenseEntity> expenses = [...expenseProvider.expenses];

      final SheetExporter sheetExporter = SheetExporter();

      bool seeAllMonths = configProvider.getConfig(ConfigName.seeAllMonths);
      DateTime month = focusedMonthProvider.getMonth();
      if (!seeAllMonths) {
        expenses = expenses
            .where(
              (expense) => expense.date.year == month.year && expense.date.month == month.month,
            )
            .toList();
      }
      final String filePath = await sheetExporter.exportToExcel(domains, categories, expenses);
      showToast(context, 'Expenses exported to: $filePath');
    } catch (e) {
      showToast(context, 'Failed to export exercises');
    }
  }

  void onPressedExportAction(ConfigProvider configProvider, BuildContext context) {
    Map<String, dynamic> jsonAppData = configProvider.getAllAppPersistedData();
    String fileName = configProvider.getExportDataFilename();
    configProvider
        .exportJSONFile(jsonAppData, fileName)
        .then((res) => handleToastFileExportResult(res, context, fileName));
  }

  void handleToastFileExportResult(bool res, BuildContext context, String fileName) {
    if (res) {
      String topLevelFolderName = Platform.isAndroid ? 'Android/data' : 'Download';
      showToast(context, 'File exported $fileName exported');
      // showToast(context, "File exported to $topLevelFolderName folder as $fileName");
    } else {
      showToast(context, 'Error exporting file :(');
    }
  }

  void showConfirmDialog(
    BuildContext context,
    VoidCallback onConfirm,
    VoidCallback onCancel,
    String title,
    String body,
  ) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // set up the buttons using the dialog context
        Widget cancelButton = TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onCancel();
          },
        );
        Widget continueButton = TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Theme.of(dialogContext).colorScheme.secondary.withOpacity(0.05),
            ),
          ),
          child: const Text('Continue'),
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onConfirm();
          },
        );

        // set up the AlertDialog
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [cancelButton, continueButton],
        );
      },
    );
  }

  void handleImportFile(
    BuildContext context,
    ConfigProvider configProvider,
    CategoryProvider categoryProvider,
    ExpenseProvider expenseProvider,
    DomainProvider domainProvider,
  ) async {
    Map<String, dynamic>? jsonData = await configProvider.importJsonDataFile();
    if (jsonData != null) {
      categoryProvider.setDataFromImport(jsonData[CategoryEntity.PERSIST_NAME]);
      expenseProvider.setDataFromImport(jsonData[ExpenseEntity.PERSIST_NAME]);
      domainProvider.setDataFromImport(jsonData[DomainEntity.PERSIST_NAME]);
      showToast(context, 'Data imported', duration: const Duration(seconds: 2));
    }
    return;
  }
}
