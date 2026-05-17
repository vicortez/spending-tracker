import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/components/ui/my_bottom_sheet.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/focused_month/focused_month_provider.dart';
import 'package:spending_tracker/services/logger_service.dart';
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
                    const SizedBox(height: 15),
                    CoolButton(
                      text: 'Merge expenses files',
                      onPressed: kIsWeb ? null : () => handleMergeFiles(context, configProvider),
                      type: ButtonType.normal,
                    ),
                    if (kIsWeb)
                      const Text(
                        'Merging is currently unavailable for web',
                        style: TextStyle(fontSize: 12),
                      ),
                    const SizedBox(height: 15),
                    CoolButton(
                      text: 'Export backups',
                      onPressed: kIsWeb
                          ? null
                          : () => onPressedExportBackupsAction(configProvider, context),
                      type: ButtonType.normal,
                    ),
                    if (kIsWeb)
                      const Text(
                        'Exporting is currently unavailable for web',
                        style: TextStyle(fontSize: 12),
                      ),
                    const SizedBox(height: 15),
                    CoolButton(
                      text: 'View Error Logs',
                      onPressed: () => _showErrorLogsBottomSheet(context),
                      type: ButtonType.normal,
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

  void onPressedExportBackupsAction(ConfigProvider configProvider, BuildContext context) {
    Map<String, dynamic>? backupsData = configProvider.getBackupsData();
    if (backupsData == null) {
      showToast(context, 'No backups found');
      return;
    }
    String fileName = 'spending-tracker-backups-${DateTime.now().toString().substring(0, 10)}';
    configProvider
        .exportJSONFile(backupsData, fileName)
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

  void handleMergeFiles(BuildContext context, ConfigProvider configProvider) async {
    List<Map<String, dynamic>>? filesData = await configProvider.pickMultipleJsonFiles();

    if (filesData == null) {
      if (context.mounted) {
        showToast(context, 'Please select 2 or more files');
      }
      return;
    }

    Map<String, dynamic>? mergedData = configProvider.mergeJsonFiles(filesData);

    if (mergedData == null) {
      if (context.mounted) {
        showToast(
          context,
          'Merge failed: Inconsistent IDs or names for domains/categories',
          duration: const Duration(seconds: 4),
        );
      }
      return;
    }

    if (context.mounted) {
      String fileName = 'merged-expenses-${DateTime.now().toString().substring(0, 10)}';
      configProvider
          .exportJSONFile(mergedData, fileName)
          .then((res) => handleToastFileExportResult(res, context, fileName));
    }
  }

  void _showErrorLogsBottomSheet(BuildContext context) {
    final logs = LoggerService.getErrorLogs();

    showMyBottomSheet(
      context: context,
      title: 'Error Logs',
      content: logs.isEmpty
          ? const Center(
              child: Padding(padding: EdgeInsets.all(24.0), child: Text('No errors recorded')),
            )
          : Column(
              children: [
                ...logs.map(
                  (log) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(log, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 16),
                CoolButton(
                  text: 'Clear Logs',
                  type: ButtonType.danger,
                  onPressed: () {
                    LoggerService.clearLogs();
                    Navigator.of(context).pop();
                    showToast(context, 'Logs cleared');
                  },
                ),
              ],
            ),
    );
  }
}
