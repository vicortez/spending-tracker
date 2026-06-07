import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/interfaces/persistable_store.dart';
import 'package:spending_tracker/repository/services/persistence_service.dart';
import 'package:spending_tracker/services/logger_service.dart';

class ExpenseProvider with ChangeNotifier implements PersistableStore<List<ExpenseEntity>> {
  List<ExpenseEntity> expenses = [];
  PersistenceService? _persistenceService;
  bool _loadSuccessful = false;

  @override
  Future<void> set(List<ExpenseEntity> newExpenses, {bool syncStorage = true}) async {
    expenses = newExpenses;
    notifyListeners();
    if (syncStorage) {
      await persistChanges();
    }
  }

  Future<void> setDataFromImport(dynamic data) async {
    if (_persistenceService == null) return;

    dynamic value = data ?? '[]';
    await _persistenceService!.saveRawData(value, ExpenseEntity.PERSIST_NAME);
    try {
      expenses = await _persistenceService!.loadRecords(
        ExpenseEntity.fromMap,
        ExpenseEntity.PERSIST_NAME,
      );
      _loadSuccessful = true;
      notifyListeners();
    } catch (e) {
      _loadSuccessful = false;
      LoggerService.logError('Failed to load imported expenses: $e');
    }
  }

  Future<bool> updateExpense(int id, int categoryId, double amount, DateTime date) async {
    ExpenseEntity? expense = expenses.firstWhereOrNull((exp) => exp.id == id);
    if (expense == null) {
      return false;
    }
    expense.categoryId = categoryId;
    expense.amount = amount;
    expense.date = date;
    await persistChanges();
    notifyListeners();
    return true;
  }

  Future<void> loadFromLocalStorage(SharedPreferences prefs) async {
    _persistenceService = PersistenceService(prefs);
    try {
      final String? encodedData = prefs.getString(ExpenseEntity.PERSIST_NAME);

      // Robust check: If isFirstRun is false, we EXPECT data to be present.
      // If it's null, it might be an intermittent OS failure.
      final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

      if (encodedData == null && !isFirstRun) {
        _loadSuccessful = false;
        LoggerService.logError(
          'Critical: Storage returned null for expenses, but this is not the first run. Aborting to prevent data loss.',
        );
      } else {
        expenses = await _persistenceService!.loadRecords(
          ExpenseEntity.fromMap,
          ExpenseEntity.PERSIST_NAME,
        );
        _loadSuccessful = true;
      }
    } catch (e) {
      _loadSuccessful = false;
    }
    notifyListeners();
  }

  Future<void> addExpense(
    int categoryId,
    String categoryName,
    double amount, {
    DateTime? date,
  }) async {
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
      createdAt: DateTime.now(),
    );
    expenses.add(expense);
    notifyListeners();
    await persistChanges();
  }

  Future<void> removeExpense(int id) async {
    expenses.removeWhere((exp) => exp.id == id);
    await persistChanges();
    notifyListeners();
  }

  Future<void> removeALl() async {
    expenses.clear();
    await persistChanges();
    notifyListeners();
  }

  @override
  Future<void> persistChanges() async {
    if (_persistenceService != null) {
      if (!_loadSuccessful && expenses.isNotEmpty) {
        LoggerService.logError(
          'Aborting save: Expense list was not successfully loaded from storage.',
        );
        return;
      }
      await _persistenceService!.saveRecords(expenses, ExpenseEntity.PERSIST_NAME);
    } else {
      LoggerService.logError('Critical: Persistence service is null during save attempt.');
    }
  }

  int getStorageExpenseCount(SharedPreferences prefs) {
    final String? encodedData = prefs.getString(ExpenseEntity.PERSIST_NAME);
    if (encodedData == null) return 0;
    try {
      final List<dynamic> decoded = json.decode(encodedData) as List<dynamic>;
      return decoded.length;
    } catch (_) {
      return 0;
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
