// Global state
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/models/expense/expense.dart';

class ExpenseState extends ChangeNotifier {
  List<Expense> expenses = [];
  SharedPreferences? prefs;

  void setExpenses(List<Expense> newExpenses, {bool syncStorage = true}) {
    expenses = newExpenses;
    notifyListeners();
    if (syncStorage && prefs != null) {
      updateLocalStorage();
    }
  }

  bool updateExpense(int id, String categoryName, double amount, DateTime date) {
    Expense? expense = expenses.firstWhereOrNull((exp) => exp.id == id);
    if (expense == null) {
      return false;
    }
    expense.categoryName = categoryName;
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
    final String? expensesStr = prefs?.getString(Expense.PERSIST_NAME);
    if (expensesStr != null) {
      expenses = Expense.decode(expensesStr);
      notifyListeners();
    }
  }

  void addExpense(String categoryName, double amount) {
    DateTime date = DateTime.now();
    date = DateTime(date.year, date.month, date.day, date.hour, date.minute);
    Expense expense = Expense(id: getNextId(), categoryName: categoryName, amount: amount, date: date);
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
    prefs?.setString(Expense.PERSIST_NAME, Expense.encode(expenses));
  }

  int getNextId() {
    if (expenses.isEmpty) {
      return 1;
    } else {
      return expenses.map((e) => e.id).reduce(max) + 1;
    }
  }

  bool existsEspenseForCategory(String catName) {
    return expenses.any(
      (exp) => exp.categoryName == catName,
    );
  }
}