import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/config/config_name.dart';
import 'package:spending_tracker/config/config_state.dart';
import 'package:spending_tracker/models/category/category.dart';
import 'package:spending_tracker/models/category/category_state.dart';
import 'package:spending_tracker/models/expense/expense.dart';
import 'package:spending_tracker/models/expense/expense_state.dart';
import 'package:spending_tracker/models/focused_month/focused_month_state.dart';
import 'package:spending_tracker/models/month_names.dart';
import 'package:spending_tracker/pages/edit_expense_page.dart';
import 'package:spending_tracker/utils/color_utils.dart';

class RowData {
  Expense? expense;
  Color backgroundColor;
  bool isAggregate;
  double? total;
  String catName;

  RowData(this.expense, this.backgroundColor, this.isAggregate, this.total, this.catName);
}

class SpendingReportPage extends StatelessWidget {
  const SpendingReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    var expenseState = context.watch<ExpenseState>();
    var categoryState = context.watch<CategoryState>();
    var focusedMonthState = context.watch<FocusedMonthState>();
    var configState = context.watch<ConfigState>();

    bool seeAllMonths = configState.getConfig(ConfigName.seeAllMonths);
    DateTime month = focusedMonthState.getMonth();
    List<Expense> expenses = [...expenseState.expenses];
    List<Category> categories = [...categoryState.categories];
    expenses.sort((a, b) => a.date.compareTo(b.date));
    if (!seeAllMonths) {
      expenses =
          expenses.where((expense) => expense.date.year == month.year && expense.date.month == month.month).toList();
    }

    // Quick and dirty way. Not scalable. Ideally we want a global object dictionary with theme name as keys.
    // or maybe there is a "fluttery" way to do it.
    bool isDarkMode = Theme.of(context).colorScheme.brightness == Brightness.dark;
    Color? tableBackground1 = Theme.of(context).colorScheme.background;
    Color? tableBackground2 = isDarkMode ? Colors.grey[850] : Colors.grey[300];

    List<RowData> rowData = getRowsData(
        expenses, tableBackground1, tableBackground2, darken(Theme.of(context).colorScheme.primary, 30), categories);
    return SelectionArea(
      child: Column(
        children: [
          Text("Showing report for ${seeAllMonths ? "all months" : monthNames[month.month]}"),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: rowData.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader(index, context);
                }
                return _buildRow(index, context, rowData[index - 1]);
              },
            ),
          )
        ],
      ),
    );
  }

  _buildHeader(int index, context) {
    double columnSeparatorSize = 3;
    var textStyle = const TextStyle(fontWeight: FontWeight.w800);
    return SizedBox(
      height: 40,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildExpandedCell(8, "Category", customStyle: textStyle),
                _buildExpandedCell(6, "Date", customStyle: textStyle),
                _buildExpandedCell(7, "Amount", customStyle: textStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildRow(int index, BuildContext context, RowData rowData) {
    TextStyle? style;
    String dateColText = rowData.expense != null ? rowData.expense!.date.toString().substring(0, 10) : "?";
    double minHeight = 40;
    int amountColFlex = 5;
    double? amount = rowData.expense?.amount;

    if (rowData.isAggregate) {
      minHeight = 30;
      amountColFlex = 7;
      dateColText = "Total: ";
      style = const TextStyle(fontWeight: FontWeight.w800);
      amount = rowData.total;
    }

    String amountText = amount != null ? toMaxDecimalPlacesOmitTrailingZeroes(amount, 2) : "?";

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Container(
            color: rowData.backgroundColor,
            child: Row(
              children: [
                _buildExpandedCell(8, rowData.catName, customStyle: style),
                _buildExpandedCell(6, dateColText, customStyle: style),
                _buildExpandedCell(amountColFlex, amountText, customStyle: style),
                if (!rowData.isAggregate) _buildEditCell(2, rowData.expense, context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildExpandedCell(int flex, String content,
      {TextStyle? customStyle, Widget? customWidget, TextAlign? textAlign = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.only(left: 4),
        child: customWidget ??
            Text(
              textAlign: textAlign,
              content,
              style: customStyle,
            ),
      ),
    );
  }

  _buildEditCell(int flex, expense, context) {
    return Expanded(
        flex: flex,
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 30),
            child: IconButton(
              iconSize: 16,
              icon: const Icon(
                Icons.edit_outlined,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditExpensePage(
                            expense: expense,
                          )),
                );
              },
            )));
  }

  String toMaxDecimalPlacesOmitTrailingZeroes(double n, int places) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : places);
  }

  List<RowData> getRowsData(List<Expense> expenses, Color tableBackground1, Color? tableBackground2,
      Color aggBackgroundColor, List<Category> categories) {
    final SplayTreeMap<String, List<Expense>> orderedExpensesMap =
        SplayTreeMap<String, List<Expense>>((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    for (var expense in expenses) {
      Category category = categories.firstWhere((element) => element.id == expense.categoryId,
          orElse: () => Category(id: -1, name: "<category not found>", enabled: true));
      if (category.enabled) {
        orderedExpensesMap.putIfAbsent(category.name, () => <Expense>[]).add(expense);
      }
    }

    List<RowData> tableLinesData = [];
    for (var expenseGroupEntry in orderedExpensesMap.entries) {
      String catName = expenseGroupEntry.key;
      List<Expense> groupExpenses = expenseGroupEntry.value;
      for (var expense in groupExpenses) {
        var backgroundColor = tableLinesData.length % 2 == 0 ? tableBackground1 : tableBackground2;
        tableLinesData.add(RowData(expense, backgroundColor!, false, null, catName));
      }
      var backgroundColor = aggBackgroundColor;
      double total = groupExpenses.map((exp) => exp.amount).reduce((acc, element) => acc + element);
      tableLinesData.add(RowData(null, backgroundColor, true, total, catName));
    }
    return tableLinesData;
  }
}
