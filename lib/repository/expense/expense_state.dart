// Global state
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/expense/expense.dart';

class ExpenseState extends ChangeNotifier {
  List<ExpenseEntity> expenses = [];
  SharedPreferences? prefs;

  void setExpenses(List<ExpenseEntity> newExpenses, {bool syncStorage = true}) {
    expenses = newExpenses;
    notifyListeners();
    if (syncStorage && prefs != null) {
      updateLocalStorage();
    }
  }

  void setDataFromImport(dynamic data) {
    dynamic value = data ?? "[]";
    prefs?.setString(ExpenseEntity.PERSIST_NAME, value);
    loadFromLocalStorage(prefs!);
  }

  bool updateExpense(int id, int categoryId, double amount, DateTime date) {
    ExpenseEntity? expense = expenses.firstWhereOrNull((exp) => exp.id == id);
    if (expense == null) {
      return false;
    }
    expense.categoryId = categoryId;
    expense.amount = amount;
    expense.date = date;
    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
    return true;
  }

  void loadFromLocalStorage(SharedPreferences prefs) {
    this.prefs = prefs;
    final String? expensesStr = prefs.getString(ExpenseEntity.PERSIST_NAME);
    if (expensesStr != null) {
      expenses = ExpenseEntity.decode(expensesStr);
      notifyListeners();
    }
  }

  void addExpense(int categoryId, String categoryName, double amount) {
    DateTime date = DateTime.now();
    date = DateTime(date.year, date.month, date.day, date.hour, date.minute);
    ExpenseEntity expense = ExpenseEntity(id: getNextId(), categoryId: categoryId, amount: amount, date: date);
    expenses.add(expense);

    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  void removeExpense(int id) {
    expenses.removeWhere((exp) => exp.id == id);
    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  void removeALl() {
    expenses.clear();
    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  void updateLocalStorage() {
    prefs?.setString(ExpenseEntity.PERSIST_NAME, ExpenseEntity.encode(expenses));
  }

  int getNextId() {
    if (expenses.isEmpty) {
      return 1;
    } else {
      return expenses.map((e) => e.id).reduce(max) + 1;
    }
  }

  bool existsExpenseForCategory(int catId) {
    return expenses.any(
      (exp) => (exp.categoryId == catId),
    );
  }
}
