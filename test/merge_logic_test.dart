import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/expense/expense.dart';

void main() {
  group('ConfigProvider - Merge Logic', () {
    late ConfigProvider configProvider;

    setUp(() {
      configProvider = ConfigProvider();
    });

    test('should merge two consistent files and remap expense IDs', () {
      final file1 = {
        DomainEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Personal'},
        ]),
        CategoryEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Food', 'domainId': 1},
        ]),
        ExpenseEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'categoryId': 1, 'amount': 10.0, 'date': 123456789},
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
          {'id': 1, 'categoryId': 1, 'amount': 20.0, 'date': 987654321},
        ]),
      };

      final result = configProvider.mergeJsonFiles([file1, file2]);

      expect(result, isNotNull);

      final mergedExpenses = json.decode(result![ExpenseEntity.PERSIST_NAME]) as List<dynamic>;
      expect(mergedExpenses.length, 2);
      expect(mergedExpenses[0]['id'], 1);
      expect(mergedExpenses[1]['id'], 2); // Remapped
      expect(mergedExpenses[1]['amount'], 20.0);
    });

    test('should fail if domain names have different IDs', () {
      final file1 = {
        DomainEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Personal'},
        ]),
        CategoryEntity.PERSIST_NAME: '[]',
        ExpenseEntity.PERSIST_NAME: '[]',
      };

      final file2 = {
        DomainEntity.PERSIST_NAME: json.encode([
          {'id': 2, 'name': 'Personal'},
        ]),
        CategoryEntity.PERSIST_NAME: '[]',
        ExpenseEntity.PERSIST_NAME: '[]',
      };

      final result = configProvider.mergeJsonFiles([file1, file2]);
      expect(result, isNull);
    });

    test('should fail if category names have different IDs', () {
      final file1 = {
        DomainEntity.PERSIST_NAME: '[]',
        CategoryEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Food'},
        ]),
        ExpenseEntity.PERSIST_NAME: '[]',
      };

      final file2 = {
        DomainEntity.PERSIST_NAME: '[]',
        CategoryEntity.PERSIST_NAME: json.encode([
          {'id': 2, 'name': 'Food'},
        ]),
        ExpenseEntity.PERSIST_NAME: '[]',
      };

      final result = configProvider.mergeJsonFiles([file1, file2]);
      expect(result, isNull);
    });

    test('should handle new domains and categories correctly', () {
      final file1 = {
        DomainEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Personal'},
        ]),
        CategoryEntity.PERSIST_NAME: json.encode([
          {'id': 1, 'name': 'Food'},
        ]),
        ExpenseEntity.PERSIST_NAME: '[]',
      };

      final file2 = {
        DomainEntity.PERSIST_NAME: json.encode([
          {'id': 2, 'name': 'Work'},
        ]),
        CategoryEntity.PERSIST_NAME: json.encode([
          {'id': 2, 'name': 'Software'},
        ]),
        ExpenseEntity.PERSIST_NAME: '[]',
      };

      final result = configProvider.mergeJsonFiles([file1, file2]);

      expect(result, isNotNull);
      final mergedDomains = json.decode(result![DomainEntity.PERSIST_NAME]) as List<dynamic>;
      final mergedCategories = json.decode(result![CategoryEntity.PERSIST_NAME]) as List<dynamic>;

      expect(mergedDomains.length, 2);
      expect(mergedCategories.length, 2);
    });
  });
}
