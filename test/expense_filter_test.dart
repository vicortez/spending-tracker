import 'package:flutter_test/flutter_test.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/expense/expense_filter.dart';

void main() {
  group('ExpenseFilter', () {
    late List<ExpenseEntity> expenses;
    late List<CategoryEntity> categories;
    late List<DomainEntity> domains;

    setUp(() {
      // Create test categories and domains
      domains = [DomainEntity(id: 1, name: 'Personal'), DomainEntity(id: 2, name: 'Work')];

      categories = [
        CategoryEntity(id: 1, name: 'Food', enabled: true, domainId: 1),
        CategoryEntity(id: 2, name: 'Transport', enabled: true, domainId: 1),
        CategoryEntity(id: 3, name: 'Entertainment', enabled: true, domainId: 2),
        CategoryEntity(id: 4, name: 'Utilities', enabled: true, domainId: null),
      ];

      // Create test expenses with different dates
      expenses = [
        ExpenseEntity(
          id: 1,
          categoryId: 1,
          amount: 50.0,
          date: DateTime(2024, 1, 15),
          createdAt: DateTime(2024, 1, 20),
        ),
        ExpenseEntity(
          id: 2,
          categoryId: 2,
          amount: 30.0,
          date: DateTime(2024, 2, 10),
          createdAt: DateTime(2024, 2, 15),
        ),
        ExpenseEntity(
          id: 3,
          categoryId: 3,
          amount: 100.0,
          date: DateTime(2024, 3, 5),
          createdAt: DateTime(2024, 3, 10),
        ),
        ExpenseEntity(
          id: 4,
          categoryId: 1,
          amount: 75.0,
          date: DateTime(2024, 1, 25),
          createdAt: DateTime(2024, 1, 30),
        ),
        ExpenseEntity(
          id: 5,
          categoryId: 4,
          amount: 200.0,
          date: DateTime(2024, 4, 12),
          createdAt: DateTime(2024, 4, 20),
        ),
      ];
    });

    test('should return all expenses when no filters applied', () {
      final filter = ExpenseFilter();
      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 5);
      expect(result, expenses);
    });

    test('should filter by createdAt date range', () {
      final filter = ExpenseFilter(
        createdAtRange: DateRange(start: DateTime(2024, 2, 1), end: DateTime(2024, 3, 31)),
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 2);
      expect(result.map((e) => e.id), [2, 3]);
    });

    test('should filter by createdAt with only start date', () {
      final filter = ExpenseFilter(createdAtRange: DateRange(start: DateTime(2024, 3, 1)));

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 2);
      expect(result.map((e) => e.id), [3, 5]);
    });

    test('should filter by createdAt with only end date', () {
      final filter = ExpenseFilter(createdAtRange: DateRange(end: DateTime(2024, 2, 20)));

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 3);
      expect(result.map((e) => e.id), [1, 2, 4]);
    });

    test('should filter by expense date range', () {
      final filter = ExpenseFilter(
        expenseDateRange: DateRange(start: DateTime(2024, 2, 1), end: DateTime(2024, 3, 31)),
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 2);
      expect(result.map((e) => e.id), [2, 3]);
    });

    test('should filter by expense date with only start date', () {
      final filter = ExpenseFilter(expenseDateRange: DateRange(start: DateTime(2024, 3, 1)));

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 2);
      expect(result.map((e) => e.id), [3, 5]);
    });

    test('should filter by expense date with only end date', () {
      final filter = ExpenseFilter(expenseDateRange: DateRange(end: DateTime(2024, 2, 15)));

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 3);
      expect(result.map((e) => e.id), [1, 2, 4]);
    });

    test('should filter by month', () {
      final filter = ExpenseFilter(month: 1);

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 2);
      expect(result.map((e) => e.id), [1, 4]);
    });

    test('should filter by year', () {
      final filter = ExpenseFilter(year: 2024);

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 5);
    });

    test('should filter by month and year', () {
      final filter = ExpenseFilter(month: 2, year: 2024);

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 1);
      expect(result.first.id, 2);
    });

    test('should filter by single category', () {
      final filter = ExpenseFilter(categoryIds: [1]);

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 2);
      expect(result.map((e) => e.id), [1, 4]);
    });

    test('should filter by multiple categories', () {
      final filter = ExpenseFilter(categoryIds: [1, 2]);

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 3);
      expect(result.map((e) => e.id), [1, 2, 4]);
    });

    test('should filter by domain', () {
      final filter = ExpenseFilter(domainIds: [1]);

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 3);
      expect(result.map((e) => e.id), [1, 2, 4]);
    });

    test('should filter by multiple domains', () {
      final filter = ExpenseFilter(domainIds: [1, 2]);

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 4);
      expect(result.map((e) => e.id), [1, 2, 3, 4]);
    });

    test(
      'should exclude expenses with categories that have no domain when filtering by domain',
      () {
        final filter = ExpenseFilter(domainIds: [1]);

        final result = filterExpenses(
          expenses: expenses,
          filter: filter,
          categories: categories,
          domains: domains,
        );

        // Expense 5 has categoryId 4, which has no domain, so it should be excluded
        expect(result.any((e) => e.id == 5), isFalse);
      },
    );

    test('should sort by createdAt ascending', () {
      final filter = ExpenseFilter(
        sortBy: [SortCriteria(field: SortField.createdAt, order: SortOrder.ascending)],
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 5);
      expect(result.map((e) => e.id), [1, 4, 2, 3, 5]);
    });

    test('should sort by createdAt descending', () {
      final filter = ExpenseFilter(
        sortBy: [SortCriteria(field: SortField.createdAt, order: SortOrder.descending)],
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 5);
      expect(result.map((e) => e.id), [5, 3, 2, 4, 1]);
    });

    test('should sort by expenseDate ascending', () {
      final filter = ExpenseFilter(
        sortBy: [SortCriteria(field: SortField.expenseDate, order: SortOrder.ascending)],
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 5);
      expect(result.map((e) => e.id), [1, 4, 2, 3, 5]);
    });

    test('should sort by expenseDate descending', () {
      final filter = ExpenseFilter(
        sortBy: [SortCriteria(field: SortField.expenseDate, order: SortOrder.descending)],
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 5);
      expect(result.map((e) => e.id), [5, 3, 2, 4, 1]);
    });

    test('should apply multiple sort criteria', () {
      // Add another expense with same date as expense 1 but different createdAt
      final testExpenses = [
        ...expenses,
        ExpenseEntity(
          id: 6,
          categoryId: 1,
          amount: 60.0,
          date: DateTime(2024, 1, 15), // Same as expense 1
          createdAt: DateTime(2024, 1, 25), // Different createdAt
        ),
      ];

      final filter = ExpenseFilter(
        sortBy: [
          SortCriteria(field: SortField.expenseDate, order: SortOrder.ascending),
          SortCriteria(field: SortField.createdAt, order: SortOrder.ascending),
        ],
      );

      final result = filterExpenses(
        expenses: testExpenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      // Expense 1 and 6 have same date, so should be sorted by createdAt
      // Expense 1 has createdAt Jan 20, Expense 6 has createdAt Jan 25
      final jan15Expenses = result.where((e) => e.date.day == 15 && e.date.month == 1).toList();
      expect(jan15Expenses.map((e) => e.id), [1, 6]);
    });

    test('should combine filters and sorting', () {
      final filter = ExpenseFilter(
        month: 1,
        categoryIds: [1],
        sortBy: [SortCriteria(field: SortField.expenseDate, order: SortOrder.descending)],
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 2);
      expect(result.map((e) => e.id), [4, 1]); // Sorted by date descending
    });

    test('should return empty list when no expenses match filter', () {
      final filter = ExpenseFilter(month: 12);

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result, isEmpty);
    });

    test('should handle empty expense list', () {
      final filter = ExpenseFilter(month: 1);

      final result = filterExpenses(
        expenses: [],
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result, isEmpty);
    });

    test('should handle complex multi-filter scenario', () {
      final filter = ExpenseFilter(
        expenseDateRange: DateRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 3, 31)),
        categoryIds: [1, 2],
        sortBy: [SortCriteria(field: SortField.expenseDate, order: SortOrder.ascending)],
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 3);
      expect(result.map((e) => e.id), [1, 4, 2]);
    });

    test('should handle date range edge cases - same day for start and end', () {
      final filter = ExpenseFilter(
        expenseDateRange: DateRange(start: DateTime(2024, 1, 15), end: DateTime(2024, 1, 15)),
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test('should handle empty categoryIds list as no filter', () {
      final filter = ExpenseFilter(categoryIds: []);

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 5);
    });

    test('should handle empty domainIds list as no filter', () {
      final filter = ExpenseFilter(domainIds: []);

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      expect(result.length, 5);
    });

    test('should sort by domainName ascending', () {
      final filter = ExpenseFilter(
        sortBy: [SortCriteria(field: SortField.domainName, order: SortOrder.ascending)],
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      // Domains are: 1 (Personal), 2 (Work). Expense 5 has cat 4 with no domain (Unknown).
      // Personal vs Work vs Unknown
      // Alphabetical: '' (Utilities/Unknown) < 'Personal' (Food, Transport) < 'Work' (Entertainment)
      // Actual result [5, 1, 2, 4, 3] means:
      // 5: Utilities (Domain '')
      // 1: Food (Domain 'Personal')
      // 2: Transport (Domain 'Personal')
      // 4: Food (Domain 'Personal')
      // 3: Entertainment (Domain 'Work')
      expect(result.map((e) => e.id), [5, 1, 2, 4, 3]);
    });

    test('should sort by categoryName ascending', () {
      final filter = ExpenseFilter(
        sortBy: [SortCriteria(field: SortField.categoryName, order: SortOrder.ascending)],
      );

      final result = filterExpenses(
        expenses: expenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      // Categories: Food (1, 4), Transport (2), Entertainment (3), Utilities (5)
      // Alphabetical: Entertainment (3) < Food (1, 4) < Transport (2) < Utilities (5)
      expect(result.map((e) => e.id), [3, 1, 4, 2, 5]);
    });

    test('should handle multi-level sort (Domain ASC, Category ASC, Date DESC)', () {
      // Add an expense to categories to test tie-breaking
      final testExpenses = [
        ...expenses,
        ExpenseEntity(
          id: 6,
          categoryId: 1,
          amount: 10.0,
          date: DateTime(2024, 1, 10), // Food, Personal, Jan 10
        ),
      ];

      final filter = ExpenseFilter(
        sortBy: [
          SortCriteria(field: SortField.domainName, order: SortOrder.ascending),
          SortCriteria(field: SortField.categoryName, order: SortOrder.ascending),
          SortCriteria(field: SortField.expenseDate, order: SortOrder.descending),
        ],
      );

      final result = filterExpenses(
        expenses: testExpenses,
        filter: filter,
        categories: categories,
        domains: domains,
      );

      // Domain '' (Utilities): [5]
      // Domain 'Personal' (Food, Transport):
      //   Category 'Food': [4 (Jan 25), 1 (Jan 15), 6 (Jan 10)] sorted DESC
      //   Category 'Transport': [2]
      // Domain 'Work' (Entertainment): [3]

      expect(result.map((e) => e.id), [5, 4, 1, 6, 2, 3]);
    });
  });

  group('DateRange', () {
    test('should return true for date within range', () {
      final range = DateRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 12, 31));

      expect(range.contains(DateTime(2024, 6, 15)), isTrue);
    });

    test('should return true for date at start boundary', () {
      final range = DateRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 12, 31));

      expect(range.contains(DateTime(2024, 1, 1)), isTrue);
    });

    test('should return true for date at end boundary', () {
      final range = DateRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 12, 31));

      expect(range.contains(DateTime(2024, 12, 31)), isTrue);
    });

    test('should return false for date before range', () {
      final range = DateRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 12, 31));

      expect(range.contains(DateTime(2023, 12, 31)), isFalse);
    });

    test('should return false for date after range', () {
      final range = DateRange(start: DateTime(2024, 1, 1), end: DateTime(2024, 12, 31));

      expect(range.contains(DateTime(2025, 1, 1)), isFalse);
    });

    test('should handle date with time components correctly (day precision)', () {
      final range = DateRange(
        start: DateTime(2024, 1, 1, 10, 30),
        end: DateTime(2024, 1, 31, 14, 45),
      );

      // Even though time is different, should match on day precision
      expect(range.contains(DateTime(2024, 1, 15, 23, 59)), isTrue);
      expect(range.contains(DateTime(2024, 1, 1, 0, 0)), isTrue);
      expect(range.contains(DateTime(2024, 1, 31, 23, 59)), isTrue);
    });

    test('should return true when only start is specified and date is after', () {
      final range = DateRange(start: DateTime(2024, 1, 1));

      expect(range.contains(DateTime(2024, 6, 15)), isTrue);
      expect(range.contains(DateTime(2025, 1, 1)), isTrue);
    });

    test('should return false when only start is specified and date is before', () {
      final range = DateRange(start: DateTime(2024, 1, 1));

      expect(range.contains(DateTime(2023, 12, 31)), isFalse);
    });

    test('should return true when only end is specified and date is before', () {
      final range = DateRange(end: DateTime(2024, 12, 31));

      expect(range.contains(DateTime(2024, 6, 15)), isTrue);
      expect(range.contains(DateTime(2023, 1, 1)), isTrue);
    });

    test('should return false when only end is specified and date is after', () {
      final range = DateRange(end: DateTime(2024, 12, 31));

      expect(range.contains(DateTime(2025, 1, 1)), isFalse);
    });

    test('should return true when no boundaries specified', () {
      final range = DateRange();

      expect(range.contains(DateTime(2024, 1, 1)), isTrue);
      expect(range.contains(DateTime(2025, 12, 31)), isTrue);
      expect(range.contains(DateTime(2000, 1, 1)), isTrue);
    });
  });
}
