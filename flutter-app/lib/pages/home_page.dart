import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/components/ui/add_expense_bottom_sheet.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/settings/settings_name.dart';
import 'package:spending_tracker/repository/settings/settings_provider.dart';
import 'package:spending_tracker/services/logger_service.dart';
import 'package:spending_tracker/utils/toast_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final expenseAmountTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var categoryProvider = context.watch<CategoryProvider>();
    var domainProvider = context.watch<DomainProvider>();

    List<CategoryEntity> categories = categoryProvider.getCategories();
    List<DomainEntity> domains = domainProvider.domains;
    domains.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    LinkedHashMap<DomainEntity, List<CategoryEntity>> catByDomain = LinkedHashMap();

    for (DomainEntity domain in domains) {
      List<CategoryEntity> foundCategories = categories
          .where((cat) => cat.domainId == domain.id)
          .toList();
      if (foundCategories.isNotEmpty) {
        catByDomain[domain] = foundCategories;
      }
    }
    List<CategoryEntity> noDomainCategories = categories
        .where((cat) => cat.domainId == null)
        .toList();
    if (noDomainCategories.isNotEmpty) {
      catByDomain[DomainEntity(id: -1, name: 'Categories with no domain')] = noDomainCategories;
    }

    return Center(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: catByDomain.length,
              separatorBuilder: (BuildContext ctx, int index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                DomainEntity domain = catByDomain.keys.elementAt(index);
                String domainLabel = domain.name;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    Text(domainLabel, style: Theme.of(context).textTheme.titleMedium),
                    ListView.separated(
                      itemBuilder: (context, index2) {
                        var category = catByDomain[domain]![index2];
                        return CoolButton(
                          text: category.name,
                          onPressed: () {
                            handleSubmitExpense(
                              category.id,
                              category.name,
                              expenseAmountTextController.text,
                            );
                          },
                          onHold: () {
                            final domainName = category.domainId != null
                                ? domainLabel
                                : 'No domain';
                            showAddExpenseBottomSheet(
                              context: context,
                              categoryId: category.id,
                              categoryName: category.name,
                              domainName: domainName,
                              expenseAmount: expenseAmountTextController.text,
                            );
                          },
                          type: ButtonType.theme,
                          outline: true,
                          baseColor: Colors.grey[900],
                          // baseColor: Colors.teal[900],
                          textColor: Colors.teal,
                        );
                      },
                      separatorBuilder: (BuildContext ctx, int index) => const SizedBox(height: 6),
                      itemCount: catByDomain[domain]!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  ],
                );
              },
            ),
          ),
          TextField(
            autofocus: true,

            controller: expenseAmountTextController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: '💸 Register expense',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d{0,2}$'))],
          ),
        ],
      ),
    );
  }

  void handleSubmitExpense(int categoryId, String categoryName, String text) async {
    double? amount = double.tryParse(text);
    if (amount == null) {
      showToast(context, 'Invalid expense');
    } else {
      final expenseProvider = context.read<ExpenseProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      final bool developerMode = settingsProvider.getConfig(SettingsName.developerMode) ?? false;

      final int memoryBefore = expenseProvider.expenses.length;
      int storageBefore = 0;
      SharedPreferences? prefs;

      if (developerMode) {
        prefs = await SharedPreferences.getInstance();
        storageBefore = expenseProvider.getStorageExpenseCount(prefs);
      }

      await expenseProvider.addExpense(categoryId, categoryName, amount);

      final int memoryAfter = expenseProvider.expenses.length;

      if (memoryAfter == memoryBefore) {
        LoggerService.logError(
          'Failed to add expense: List size did not change after adding $amount to $categoryName',
        );
      }

      if (developerMode && prefs != null) {
        final int storageAfter = expenseProvider.getStorageExpenseCount(prefs);
        showToast(
          context,
          'DEBUG: Memory: $memoryBefore -> $memoryAfter | Storage: $storageBefore -> $storageAfter',
          duration: const Duration(seconds: 5),
        );
      }

      showToast(
        context,
        '$amount spent on $categoryName',
        duration: const Duration(milliseconds: 1500),
      );
      expenseAmountTextController.clear();
    }
  }
}
