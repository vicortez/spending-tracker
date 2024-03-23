import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/config/config_name.dart';
import 'package:spending_tracker/config/config_state.dart';
import 'package:spending_tracker/models/category/category_state.dart';
import 'package:spending_tracker/models/domain/domain.dart';
import 'package:spending_tracker/models/domain/domain_state.dart';
import 'package:spending_tracker/models/expense/expense.dart';
import 'package:spending_tracker/models/expense/expense_state.dart';
import 'package:spending_tracker/models/focused_month/focused_month_state.dart';

import '../models/category/category.dart';

class AccCategory {
  const AccCategory(this.catId, this.acc);

  final int? catId;
  final double acc;
}

class TestPage extends StatelessWidget {
  // final List<Sector> sectors;

  const TestPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var categoryState = context.watch<CategoryState>();
    var domainState = context.watch<DomainState>();
    var expenseState = context.watch<ExpenseState>();
    var configState = context.watch<ConfigState>();
    var focusedMonthState = context.watch<FocusedMonthState>();

    var categories = categoryState.getEnabledCategories();
    List<Domain> domains = domainState.domains;

    bool seeAllMonths = configState.getConfig(ConfigName.seeAllMonths);
    DateTime month = focusedMonthState.getMonth();
    List<Expense> expenses = [...expenseState.expenses];
    expenses.sort((a, b) => a.date.compareTo(b.date));
    if (!seeAllMonths) {
      expenses =
          expenses.where((expense) => expense.date.year == month.year && expense.date.month == month.month).toList();
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Secret tests page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Top 20 expenses"),
            Container(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: _chartSections(expenses, categories, domains),
                  centerSpaceRadius: 48.0,
                ),
              ),
            ),
            ..._chartSections(expenses, categories, domains).toList().map((section) {
              return ListTile(
                visualDensity: const VisualDensity(vertical: -3),
                leading: Container(
                  width: 12,
                  height: 12,
                  color: section.color,
                ),
                title: Text(section.title),
                titleTextStyle: const TextStyle(fontSize: 18),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _chartSections(List<Expense> expenses, List<Category> categories, List<Domain> domains) {
    HashMap<int, double> accCats = HashMap();
    for (var expense in expenses) {
      int catId = expense.categoryId ?? 999;
      accCats.putIfAbsent(catId, () => 0);
      accCats[catId] = accCats[catId]! + expense.amount;
    }
    List<AccCategory> accCatList = accCats.entries.map((e) => AccCategory(e.key, e.value)).toList();
    accCatList.sort((a, b) => -a.acc.compareTo(b.acc));

    var colors = [
      Colors.yellow,
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.grey,
      Colors.white,
      Colors.brown,
      Colors.orange
    ];

    final List<PieChartSectionData> list = [];
    for (int i = 0; i < min(accCatList.length, 20); i++) {
      var accCat = accCatList[i];
      const double radius = 40.0;
      final data = PieChartSectionData(
          color: colors[i % colors.length],
          value: accCat.acc,
          radius: radius,
          showTitle: false,
          title:
              "${categories.firstWhereOrNull((element) => accCatList[i].catId == element.id)?.name ?? "<noCat>"} \$${accCat.acc}",
          titleStyle: const TextStyle(
            fontSize: 18,
          ),
          titlePositionPercentageOffset: 1.2);
      list.add(data);
    }
    return list;
  }
}
