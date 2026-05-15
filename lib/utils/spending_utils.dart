import 'package:flutter/material.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/expense/expense.dart';

class CategorySpending {
  final int categoryId;
  final String categoryName;
  final double totalAmount;
  final Color color;

  CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.color,
  });
}

class SpendingSummary {
  final List<CategorySpending> topCategories;
  final double totalAmount;

  SpendingSummary({required this.topCategories, required this.totalAmount});
}

List<Color> spendingColors = [
  Colors.indigo,
  Colors.teal,
  Colors.amber,
  Colors.cyan,
  Colors.orange,
  Colors.pink,
  Colors.deepPurple,
  Colors.green,
  Colors.blue,
  Colors.lime,
  Colors.red,
  Colors.brown,
  Colors.blueGrey,
  Colors.deepOrange,
  Colors.lightGreen,
  Colors.lightBlue,
  Colors.purple,
  Colors.yellow,
  Colors.tealAccent,
  Colors.cyanAccent,
];

SpendingSummary getTopCategoriesSpending({
  required List<ExpenseEntity> expenses,
  required List<CategoryEntity> categories,
  required int limit,
}) {
  if (expenses.isEmpty) {
    return SpendingSummary(topCategories: [], totalAmount: 0.0);
  }

  // Group by categoryId and sum amount
  final Map<int, double> categorySums = {};
  double totalAmount = 0.0;

  for (var expense in expenses) {
    categorySums[expense.categoryId] = (categorySums[expense.categoryId] ?? 0) + expense.amount;
    totalAmount += expense.amount;
  }

  // Sort by sum descending
  final sortedIds = categorySums.keys.toList()
    ..sort((a, b) => categorySums[b]!.compareTo(categorySums[a]!));

  final List<CategorySpending> results = [];
  double othersSum = 0.0;

  for (int i = 0; i < sortedIds.length; i++) {
    final id = sortedIds[i];
    final sum = categorySums[id]!;
    final category = categories.firstWhere(
      (c) => c.id == id,
      orElse: () => CategoryEntity(id: id, name: 'Unknown', enabled: true),
    );

    if (i < limit) {
      results.add(
        CategorySpending(
          categoryId: id,
          categoryName: category.name,
          totalAmount: sum,
          color: spendingColors[i % spendingColors.length],
        ),
      );
    } else {
      othersSum += sum;
    }
  }

  if (othersSum > 0) {
    results.add(
      CategorySpending(
        categoryId: -1,
        categoryName: 'Others',
        totalAmount: othersSum,
        color: Colors.grey,
      ),
    );
  }

  return SpendingSummary(topCategories: results, totalAmount: totalAmount);
}
