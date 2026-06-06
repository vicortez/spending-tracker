import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';

void main() {
  group('Import/Export Integration Tests', () {
    late SharedPreferences prefs;
    late CategoryProvider categoryProvider;
    late ExpenseProvider expenseProvider;
    late DomainProvider domainProvider;
    late ConfigProvider configProvider;

    setUp(() async {
      // Initialize Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      // Initialize providers
      categoryProvider = CategoryProvider();
      expenseProvider = ExpenseProvider();
      domainProvider = DomainProvider();
      configProvider = ConfigProvider();

      await categoryProvider.loadFromLocalStorage(prefs);
      await expenseProvider.loadFromLocalStorage(prefs);
      await domainProvider.loadFromLocalStorage(prefs);
      await configProvider.loadFromLocalStorage(prefs);
    });

    test('Export and import categories maintains data integrity', () async {
      // 1. Setup initial data
      await categoryProvider.addCategory('Food');
      await categoryProvider.addCategory('Transport');
      await categoryProvider.addCategory('Entertainment');

      final originalCategories = categoryProvider.getCategories(enabledOnly: false);
      expect(originalCategories.length, 3);

      // 2. Export data (simulate export by getting persisted data)
      final exportedData = configProvider.getAllAppPersistedData();
      final categoriesJson = exportedData[CategoryEntity.PERSIST_NAME];

      expect(categoriesJson, isNotNull);

      // 3. Clear current data
      categoryProvider.set([], syncStorage: false);
      expect(categoryProvider.getCategories(enabledOnly: false).length, 0);

      // 4. Import data back
      await categoryProvider.setDataFromImport(categoriesJson);

      // 5. Verify data integrity
      final importedCategories = categoryProvider.getCategories(enabledOnly: false);
      expect(importedCategories.length, 3);
      expect(importedCategories[0].name, 'Food');
      expect(importedCategories[1].name, 'Transport');
      expect(importedCategories[2].name, 'Entertainment');
    });

    test('Export and import expenses maintains data integrity', () async {
      // 1. Setup initial data
      await categoryProvider.addCategory('Food');
      final categoryId = categoryProvider.getCategories()[0].id;

      await expenseProvider.addExpense(categoryId, 'Food', 50.0);
      await expenseProvider.addExpense(categoryId, 'Food', 75.5);
      await expenseProvider.addExpense(categoryId, 'Food', 100.25);

      final originalExpenses = expenseProvider.expenses;
      expect(originalExpenses.length, 3);

      // 2. Export data
      final exportedData = configProvider.getAllAppPersistedData();
      final expensesJson = exportedData[ExpenseEntity.PERSIST_NAME];

      expect(expensesJson, isNotNull);

      // 3. Clear current data
      expenseProvider.set([], syncStorage: false);
      expect(expenseProvider.expenses.length, 0);

      // 4. Import data back
      await expenseProvider.setDataFromImport(expensesJson);

      // 5. Verify data integrity
      final importedExpenses = expenseProvider.expenses;
      expect(importedExpenses.length, 3);
      expect(importedExpenses[0].amount, 50.0);
      expect(importedExpenses[1].amount, 75.5);
      expect(importedExpenses[2].amount, 100.25);
      expect(importedExpenses[0].categoryId, categoryId);
    });

    test('Export and import all app data maintains complete data integrity', () async {
      // 1. Setup complete dataset
      await categoryProvider.addCategory('Food');
      await categoryProvider.addCategory('Transport');

      final foodCategoryId = categoryProvider.getCategories()[0].id;
      final transportCategoryId = categoryProvider.getCategories()[1].id;

      await expenseProvider.addExpense(foodCategoryId, 'Food', 50.0);
      await expenseProvider.addExpense(transportCategoryId, 'Transport', 25.0);
      await expenseProvider.addExpense(foodCategoryId, 'Food', 75.5);

      await domainProvider.addDomain('Personal');
      await domainProvider.addDomain('Business');

      // Store original counts
      final originalCategoriesCount = categoryProvider.getCategories(enabledOnly: false).length;
      final originalExpensesCount = expenseProvider.expenses.length;
      final originalDomainsCount = domainProvider.domains.length;

      // 2. Export all data
      final exportedData = configProvider.getAllAppPersistedData();

      expect(exportedData[CategoryEntity.PERSIST_NAME], isNotNull);
      expect(exportedData[ExpenseEntity.PERSIST_NAME], isNotNull);
      expect(exportedData[DomainEntity.PERSIST_NAME], isNotNull);

      // 3. Clear all data
      categoryProvider.set([], syncStorage: false);
      expenseProvider.set([], syncStorage: false);
      domainProvider.set([], syncStorage: false);

      expect(categoryProvider.getCategories(enabledOnly: false).length, 0);
      expect(expenseProvider.expenses.length, 0);
      expect(domainProvider.domains.length, 0);

      // 4. Import all data back
      await categoryProvider.setDataFromImport(exportedData[CategoryEntity.PERSIST_NAME]);
      await expenseProvider.setDataFromImport(exportedData[ExpenseEntity.PERSIST_NAME]);
      await domainProvider.setDataFromImport(exportedData[DomainEntity.PERSIST_NAME]);

      // 5. Verify all data integrity
      expect(categoryProvider.getCategories(enabledOnly: false).length, originalCategoriesCount);
      expect(expenseProvider.expenses.length, originalExpensesCount);
      expect(domainProvider.domains.length, originalDomainsCount);

      // Verify specific data
      final categories = categoryProvider.getCategories(enabledOnly: false);
      expect(categories.any((c) => c.name == 'Food'), true);
      expect(categories.any((c) => c.name == 'Transport'), true);

      final expenses = expenseProvider.expenses;
      expect(expenses.any((e) => e.amount == 50.0), true);
      expect(expenses.any((e) => e.amount == 25.0), true);
      expect(expenses.any((e) => e.amount == 75.5), true);

      final domains = domainProvider.domains;
      expect(domains.any((d) => d.name == 'Personal'), true);
      expect(domains.any((d) => d.name == 'Business'), true);
    });

    test('Imported data persists correctly to SharedPreferences', () async {
      // 1. Setup initial data
      await categoryProvider.addCategory('Food');
      await expenseProvider.addExpense(1, 'Food', 100.0);

      // 2. Export data
      final exportedData = configProvider.getAllAppPersistedData();

      // 3. Create new providers (simulating app restart)
      final newCategoryProvider = CategoryProvider();
      final newExpenseProvider = ExpenseProvider();

      await newCategoryProvider.loadFromLocalStorage(prefs);
      await newExpenseProvider.loadFromLocalStorage(prefs);

      // 4. Verify data persisted from first providers
      expect(newCategoryProvider.getCategories(enabledOnly: false).length, 1);
      expect(newExpenseProvider.expenses.length, 1);

      // 5. Import different data
      final newCategoriesJson = json.encode([
        {'id': 10, 'name': 'Shopping', 'enabled': true, 'domainId': null},
        {'id': 11, 'name': 'Bills', 'enabled': true, 'domainId': null},
      ]);

      await newCategoryProvider.setDataFromImport(newCategoriesJson);

      // 6. Create another provider to verify persistence
      final verifyProvider = CategoryProvider();
      await verifyProvider.loadFromLocalStorage(prefs);

      // 7. Verify imported data persisted correctly
      final persistedCategories = verifyProvider.getCategories(enabledOnly: false);
      expect(persistedCategories.length, 2);
      expect(persistedCategories.any((c) => c.name == 'Shopping'), true);
      expect(persistedCategories.any((c) => c.name == 'Bills'), true);
    });

    test('Export handles empty data gracefully', () async {
      // Don't add any data

      // Export empty data
      final exportedData = configProvider.getAllAppPersistedData();

      // Should return null or empty strings for persistence keys
      expect(exportedData[CategoryEntity.PERSIST_NAME], isNull);
      expect(exportedData[ExpenseEntity.PERSIST_NAME], isNull);
      expect(exportedData[DomainEntity.PERSIST_NAME], isNull);
    });

    test('Import handles null/invalid data gracefully', () async {
      // Add some initial data
      await categoryProvider.addCategory('Food');
      expect(categoryProvider.getCategories(enabledOnly: false).length, 1);

      // Try to import null data
      await categoryProvider.setDataFromImport(null);

      // Provider should handle null gracefully - implementation sets '[]' for null
      // Data is cleared when null is passed
      expect(categoryProvider.getCategories(enabledOnly: false).length, 0);
    });

    test('Category relationships maintained after import/export', () async {
      // 1. Setup domain and category with relationship
      await domainProvider.addDomain('Personal');
      final domainId = domainProvider.domains[0].id;

      await categoryProvider.addCategory('Food');
      final categoryId = categoryProvider.getCategories()[0].id;
      await categoryProvider.updateCategory(categoryId, 'Food', domainId, true);

      // 2. Export data
      final exportedData = configProvider.getAllAppPersistedData();

      // 3. Clear data
      categoryProvider.set([], syncStorage: false);
      domainProvider.set([], syncStorage: false);

      // 4. Import data
      await domainProvider.setDataFromImport(exportedData[DomainEntity.PERSIST_NAME]);
      await categoryProvider.setDataFromImport(exportedData[CategoryEntity.PERSIST_NAME]);

      // 5. Verify relationship maintained
      final importedCategory = categoryProvider.getCategories()[0];
      expect(importedCategory.domainId, domainId);
      expect(domainProvider.domains.any((d) => d.id == domainId), true);
    });

    test('Expense-Category relationships maintained after import/export', () async {
      // 1. Setup category and expense with relationship
      await categoryProvider.addCategory('Food');
      final categoryId = categoryProvider.getCategories()[0].id;

      await expenseProvider.addExpense(categoryId, 'Food', 50.0);
      final expenseId = expenseProvider.expenses[0].id;

      // 2. Export data
      final exportedData = configProvider.getAllAppPersistedData();

      // 3. Clear data
      categoryProvider.set([], syncStorage: false);
      expenseProvider.set([], syncStorage: false);

      // 4. Import data
      await categoryProvider.setDataFromImport(exportedData[CategoryEntity.PERSIST_NAME]);
      await expenseProvider.setDataFromImport(exportedData[ExpenseEntity.PERSIST_NAME]);

      // 5. Verify relationship maintained
      final importedExpense = expenseProvider.getById(expenseId);
      expect(importedExpense, isNotNull);
      expect(importedExpense!.categoryId, categoryId);
      expect(categoryProvider.getCategories().any((c) => c.id == categoryId), true);
    });

    test('Expense dates preserved correctly during import/export', () async {
      // 1. Create expense with specific date
      await categoryProvider.addCategory('Food');
      final categoryId = categoryProvider.getCategories()[0].id;

      await expenseProvider.addExpense(categoryId, 'Food', 50.0);
      final originalExpense = expenseProvider.expenses[0];
      final originalDate = originalExpense.date;

      // 2. Export data
      final exportedData = configProvider.getAllAppPersistedData();

      // 3. Clear data
      expenseProvider.set([], syncStorage: false);

      // 4. Import data
      await expenseProvider.setDataFromImport(exportedData[ExpenseEntity.PERSIST_NAME]);

      // 5. Verify date preserved
      final importedExpense = expenseProvider.expenses[0];
      expect(importedExpense.date.year, originalDate.year);
      expect(importedExpense.date.month, originalDate.month);
      expect(importedExpense.date.day, originalDate.day);
      expect(importedExpense.date.hour, originalDate.hour);
      expect(importedExpense.date.minute, originalDate.minute);
    });
  });
}
