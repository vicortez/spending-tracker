import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/expense/expense.dart';

enum SortField { createdAt, expenseDate, domainName, categoryName }

enum SortOrder { ascending, descending }

class SortCriteria {
  final SortField field;
  final SortOrder order;

  SortCriteria({required this.field, required this.order});
}

class DateRange {
  final DateTime? start;
  final DateTime? end;

  DateRange({this.start, this.end});

  bool contains(DateTime date) {
    // Normalize dates to day precision for comparison
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (start != null) {
      final normalizedStart = DateTime(start!.year, start!.month, start!.day);
      if (normalizedDate.isBefore(normalizedStart)) return false;
    }

    if (end != null) {
      final normalizedEnd = DateTime(end!.year, end!.month, end!.day);
      if (normalizedDate.isAfter(normalizedEnd)) return false;
    }

    return true;
  }
}

class ExpenseFilter {
  final DateRange? createdAtRange;
  final DateRange? expenseDateRange;
  final int? month; // 1-12
  final int? year;
  final List<int>? categoryIds;
  final List<int>? domainIds;
  final List<SortCriteria> sortBy;

  ExpenseFilter({
    this.createdAtRange,
    this.expenseDateRange,
    this.month,
    this.year,
    this.categoryIds,
    this.domainIds,
    this.sortBy = const [],
  });
}

List<ExpenseEntity> filterExpenses({
  required List<ExpenseEntity> expenses,
  required ExpenseFilter filter,
  required List<CategoryEntity> categories,
  List<DomainEntity> domains = const [],
}) {
  // Filter
  var result = expenses.where((expense) {
    // Filter by createdAt range (day precision)
    if (filter.createdAtRange != null) {
      if (!filter.createdAtRange!.contains(expense.createdAt)) return false;
    }

    // Filter by expense date range (day precision)
    if (filter.expenseDateRange != null) {
      if (!filter.expenseDateRange!.contains(expense.date)) return false;
    }

    // Filter by month/year
    if (filter.month != null && expense.date.month != filter.month) return false;
    if (filter.year != null && expense.date.year != filter.year) return false;

    // Filter by category
    if (filter.categoryIds != null && filter.categoryIds!.isNotEmpty) {
      if (!filter.categoryIds!.contains(expense.categoryId)) return false;
    }

    // Filter by domain
    if (filter.domainIds != null && filter.domainIds!.isNotEmpty) {
      final category = categories.firstWhere(
        (cat) => cat.id == expense.categoryId,
        orElse: () => CategoryEntity(id: -1, name: '', enabled: false),
      );
      if (category.domainId == null || !filter.domainIds!.contains(category.domainId)) {
        return false;
      }
    }

    return true;
  }).toList();

  // Sort
  if (filter.sortBy.isNotEmpty) {
    result.sort((a, b) {
      for (var criteria in filter.sortBy) {
        int comparison = 0;
        switch (criteria.field) {
          case SortField.createdAt:
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case SortField.expenseDate:
            comparison = a.date.compareTo(b.date);
            break;
          case SortField.categoryName:
            final catA = categories.firstWhere(
              (c) => c.id == a.categoryId,
              orElse: () => categories.first,
            );
            final catB = categories.firstWhere(
              (c) => c.id == b.categoryId,
              orElse: () => categories.first,
            );
            comparison = catA.name.toLowerCase().compareTo(catB.name.toLowerCase());
            break;
          case SortField.domainName:
            final catA = categories.firstWhere(
              (c) => c.id == a.categoryId,
              orElse: () => categories.first,
            );
            final catB = categories.firstWhere(
              (c) => c.id == b.categoryId,
              orElse: () => categories.first,
            );
            final domA = domains.firstWhere(
              (d) => d.id == catA.domainId,
              orElse: () => DomainEntity(id: -1, name: ''),
            );
            final domB = domains.firstWhere(
              (d) => d.id == catB.domainId,
              orElse: () => DomainEntity(id: -1, name: ''),
            );
            comparison = domA.name.toLowerCase().compareTo(domB.name.toLowerCase());
            break;
        }

        if (criteria.order == SortOrder.descending) {
          comparison = -comparison;
        }

        if (comparison != 0) return comparison;
      }
      return 0;
    });
  }

  return result;
}
