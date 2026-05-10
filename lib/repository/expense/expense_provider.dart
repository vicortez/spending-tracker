import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/services/persistence_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<ExpenseEntity> expenses = [];
  PersistenceService? _persistenceService;

  void setExpenses(List<ExpenseEntity> newExpenses, {bool syncStorage = true}) {
    expenses = newExpenses;
    notifyListeners();
    if (syncStorage) {
      _persistChanges();
    }
  }

  Future<void> setDataFromImport(dynamic data) async {
    if (_persistenceService == null) return;

    dynamic value = data ?? '[]';
    await _persistenceService!.saveRawData(value, ExpenseEntity.PERSIST_NAME);
    expenses = await _persistenceService!.loadRecords(
      ExpenseEntity.fromMap,
      ExpenseEntity.PERSIST_NAME,
    );
    notifyListeners();
  }

  bool updateExpense(int id, int categoryId, double amount, DateTime date) {
    ExpenseEntity? expense = expenses.firstWhereOrNull((exp) => exp.id == id);
    if (expense == null) {
      return false;
    }
    expense.categoryId = categoryId;
    expense.amount = amount;
    expense.date = date;
    _persistChanges();
    notifyListeners();
    return true;
  }

  Future<void> loadFromLocalStorage(SharedPreferences prefs) async {
    _persistenceService = PersistenceService(prefs);
    expenses = await _persistenceService!.loadRecords(
      ExpenseEntity.fromMap,
      ExpenseEntity.PERSIST_NAME,
    );
    notifyListeners();
  }

  void addExpense(int categoryId, String categoryName, double amount, {DateTime? date}) {
    DateTime expenseDate = date ?? DateTime.now();
    expenseDate = DateTime(
      expenseDate.year,
      expenseDate.month,
      expenseDate.day,
      expenseDate.hour,
      expenseDate.minute,
    );
    ExpenseEntity expense = ExpenseEntity(
      id: getNextId(),
      categoryId: categoryId,
      amount: amount,
      date: expenseDate,
    );
    expenses.add(expense);
    _persistChanges();
    notifyListeners();
  }

  void removeExpense(int id) {
    expenses.removeWhere((exp) => exp.id == id);
    _persistChanges();
    notifyListeners();
  }

  void removeALl() {
    expenses.clear();
    _persistChanges();
    notifyListeners();
  }

  Future<void> _persistChanges() async {
    if (_persistenceService != null) {
      await _persistenceService!.saveRecords(
        expenses,
        ExpenseEntity.PERSIST_NAME,
      );
    }
  }

  int getNextId() {
    if (expenses.isEmpty) {
      return 1;
    } else {
      return expenses.map((e) => e.id).reduce(max) + 1;
    }
  }

  bool existsExpenseForCategory(int catId) {
    return expenses.any((exp) => (exp.categoryId == catId));
  }

  ExpenseEntity? getById(int id) {
    return expenses.firstWhereOrNull((exp) => exp.id == id);
  }
}
