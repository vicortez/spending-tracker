import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/settings/settings_provider.dart';

void main() {
  group('SettingsProvider - Merge Logic', () {
    late SettingsProvider settingsProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      settingsProvider = SettingsProvider();
    });

    test('should successfully merge two valid files with distinct expenses', () {
      final file1 = {
        DomainEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Personal'},
        ]),
        CategoryEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Food', 'domainId': 1},
        ]),
        ExpenseEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'amount': 10.0, 'categoryId': 1, 'date': 123},
        ]),
      };

      final file2 = {
        DomainEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Personal'},
        ]),
        CategoryEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Food', 'domainId': 1},
        ]),
        ExpenseEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'amount': 20.0, 'categoryId': 1, 'date': 456},
        ]),
      };

      final result = settingsProvider.mergeJsonFiles([file1, file2]);

      expect(result, isNotNull);
      final domains = json.decode(result![DomainEntity.PERSIST_NAME]) as List;
      final categories = json.decode(result[CategoryEntity.PERSIST_NAME]) as List;
      final expenses = json.decode(result[ExpenseEntity.PERSIST_NAME]) as List;

      expect(domains.length, 1);
      expect(categories.length, 1);
      expect(expenses.length, 2);
      expect(expenses[1]['id'], 2); // ID should be incremented
      expect(expenses[1]['amount'], 20.0);
    });

    test('should return null if domain names conflict with IDs', () {
      final file1 = {
        DomainEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Personal'},
        ]),
      };
      final file2 = {
        DomainEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Business'},
        ]),
      };

      final result = settingsProvider.mergeJsonFiles([file1, file2]);
      expect(result, isNull);
    });

    test('should return null if category names conflict with IDs', () {
      final file1 = {
        CategoryEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Food'},
        ]),
      };
      final file2 = {
        CategoryEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Transport'},
        ]),
      };

      final result = settingsProvider.mergeJsonFiles([file1, file2]);
      expect(result, isNull);
    });

    test('should handle missing keys gracefully', () {
      final file1 = {
        ExpenseEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'amount': 10.0, 'categoryId': 1, 'date': 123},
        ]),
      };
      final file2 = {
        ExpenseEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'amount': 20.0, 'categoryId': 1, 'date': 456},
        ]),
      };

      final result = settingsProvider.mergeJsonFiles([file1, file2]);

      expect(result, isNotNull);
      final expenses = json.decode(result![ExpenseEntity.PERSIST_NAME]) as List;
      expect(expenses.length, 2);
    });
  });
}
