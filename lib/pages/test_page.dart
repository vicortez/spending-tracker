import 'dart:collection';

//
// class TestPage extends StatelessWidget {
//   const TestPage({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     var categoryState = context.watch<CategoryState>();
//     var domainState = context.watch<DomainState>();
//     var expenseState = context.watch<ExpenseState>();
//
//     var categories = categoryState.getEnabledCategories();
//     List<Domain> domains = domainState.domains;
//     List<Expense> expenses = expenseState.expenses;
//
//     // List<AccCategory> accCats = [];
//     HashMap<int, double> accCats = HashMap();
//     for (var expense in expenses) {
//       int catId = expense.categoryId ?? 999;
//       accCats.putIfAbsent(catId, () => 0);
//       accCats[catId] = accCats[catId]! + expense.amount;
//     }
//     List<AccCategory> accCatList = accCats.entries.map((e) => AccCategory(e.key, e.value)).toList();
//     accCatList.sort((a, b) => a.acc.compareTo(b.acc));
//
//     // domains.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
//     // categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: const Text("Test ground"),
//       ),
//       body: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text("Top 5 categories with most expenses"),
//           Expanded(
//             child: PieChart(
//               PieChartData(
//                 sections: [
//                   PieChartSectionData(
//                       value: accCatList[0].acc,
//                       color: Colors.red,
//                       title: categories.firstWhere((element) => accCatList[0].catId == element.id).name,
//                       titleStyle: TextStyle(fontSize: 24)),
//                   PieChartSectionData(
//                       value: accCatList[1].acc,
//                       color: Colors.yellow,
//                       title: categories.firstWhere((element) => accCatList[1].catId == element.id).name,
//                       titleStyle: TextStyle(fontSize: 24)),
//                   PieChartSectionData(
//                       value: accCatList[2].acc,
//                       color: Colors.green,
//                       title: categories.firstWhere((element) => accCatList[2].catId == element.id).name,
//                       titleStyle: TextStyle(fontSize: 24)),
//                   PieChartSectionData(
//                       value: accCatList[3].acc,
//                       color: Colors.blue,
//                       title: categories.firstWhere((element) => accCatList[3].catId == element.id).name,
//                       titleStyle: TextStyle(fontSize: 24)),
//                   PieChartSectionData(
//                       value: accCatList[4].acc,
//                       color: Colors.purple,
//                       title: categories.firstWhere((element) => accCatList[4].catId == element.id).name,
//                       titleStyle: TextStyle(fontSize: 24)),
//                 ],
//                 sectionsSpace: 0,
//                 centerSpaceRadius: 40,
//                 borderData: FlBorderData(show: false),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
        title: Text("Tests"),
      ),
      body: PieChart(PieChartData(
        sections: _chartSections(expenses, categories, domains),
        centerSpaceRadius: 48.0,
      )),
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
    accCatList.sort((a, b) => a.acc.compareTo(b.acc));

    var colors = [Colors.yellow, Colors.blue, Colors.purple, Colors.green, Colors.red];

    final List<PieChartSectionData> list = [];
    for (int i = 0; i < accCatList.length; i++) {
      var accCat = accCatList[i];
      const double radius = 40.0;
      final data = PieChartSectionData(
        color: colors[i],
        value: accCat.acc,
        radius: radius,
        title: (categories.firstWhere((element) => accCatList[i].catId == element.id)?.name ?? "<noCat>") +
            " \$${accCat.acc}",
        titleStyle: TextStyle(fontSize: 18),
      );
      list.add(data);
    }
    return list;
  }
}
