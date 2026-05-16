import 'package:flutter_test/flutter_test.dart';
import 'package:spending_tracker/repository/expense/expense.dart';

void main() {
  group('ExpenseEntity', () {
    test('constructor should default createdAt to date if null', () {
      final date = DateTime(2024, 1, 1);
      final expense = ExpenseEntity(
        id: 1,
        categoryId: 1,
        amount: 10.0,
        date: date,
        createdAt: null,
      );

      expect(expense.createdAt, date);
    });

    test('constructor should use provided createdAt', () {
      final date = DateTime(2024, 1, 1);
      final createdAt = DateTime(2024, 1, 2);
      final expense = ExpenseEntity(
        id: 1,
        categoryId: 1,
        amount: 10.0,
        date: date,
        createdAt: createdAt,
      );

      expect(expense.createdAt, createdAt);
    });

    test('fromMap should handle missing createdAt by defaulting to date', () {
      final date = DateTime(2024, 1, 1);
      final jsonData = {
        'id': 1,
        'categoryId': 1,
        'amount': 10.0,
        'date': date.millisecondsSinceEpoch,
        // 'createdAt' is missing
      };

      final expense = ExpenseEntity.fromMap(jsonData);

      expect(expense.date, date);
      expect(expense.createdAt, date);
    });

    test('fromMap should use createdAt from JSON if present', () {
      final date = DateTime(2024, 1, 1);
      final createdAt = DateTime(2024, 1, 2);
      final jsonData = {
        'id': 1,
        'categoryId': 1,
        'amount': 10.0,
        'date': date.millisecondsSinceEpoch,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

      final expense = ExpenseEntity.fromMap(jsonData);

      expect(expense.date, date);
      expect(expense.createdAt, createdAt);
    });
  });
}
