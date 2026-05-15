import 'package:flutter/material.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/expense/expense_filter.dart';

class FilterBottomSheetContent extends StatefulWidget {
  final ExpenseFilter currentFilter;
  final List<CategoryEntity> categories;
  final Function(ExpenseFilter) onFilterChanged;

  const FilterBottomSheetContent({
    super.key,
    required this.currentFilter,
    required this.categories,
    required this.onFilterChanged,
  });

  @override
  State<FilterBottomSheetContent> createState() => _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<FilterBottomSheetContent> {
  late List<int> selectedCategoryIds;
  int? selectedYear;
  int? selectedMonth;
  int? selectedDay;

  bool last30Days = false;
  bool isInterval = false;

  int? startYear;
  int? startMonth;
  int? startDay;
  int? endYear;
  int? endMonth;
  int? endDay;

  @override
  void initState() {
    super.initState();
    selectedCategoryIds = List.from(widget.currentFilter.categoryIds ?? []);
    selectedYear = widget.currentFilter.year;
    selectedMonth = widget.currentFilter.month;
    selectedDay = widget.currentFilter.day;

    if (widget.currentFilter.expenseDateRange != null) {
      final range = widget.currentFilter.expenseDateRange!;
      final now = DateTime.now();
      final thirtyDaysAgo = DateTime(now.year, now.month, now.day - 30);

      if (range.start != null &&
          range.end != null &&
          range.start!.isAtSameMomentAs(thirtyDaysAgo) &&
          range.end!.isAtSameMomentAs(now)) {
        last30Days = true;
      } else {
        isInterval = true;
        startYear = range.start?.year;
        startMonth = range.start?.month;
        startDay = range.start?.day;
        endYear = range.end?.year;
        endMonth = range.end?.month;
        endDay = range.end?.day;
      }
    }
  }

  void _apply() {
    DateRange? expenseDateRange;

    if (last30Days) {
      final now = DateTime.now();
      expenseDateRange = DateRange(start: DateTime(now.year, now.month, now.day - 30), end: now);
    } else if (isInterval) {
      DateTime? start;
      if (startYear != null) {
        start = DateTime(startYear!, startMonth ?? 1, startDay ?? 1);
      }
      DateTime? end;
      if (endYear != null) {
        end = DateTime(endYear!, endMonth ?? 12, endDay ?? 31, 23, 59, 59);
      }
      expenseDateRange = DateRange(start: start, end: end);
    }

    final newFilter = ExpenseFilter(
      categoryIds: selectedCategoryIds,
      year: last30Days || isInterval ? null : selectedYear,
      month: last30Days || isInterval ? null : selectedMonth,
      day: last30Days || isInterval ? null : selectedDay,
      expenseDateRange: expenseDateRange,
      sortBy: widget.currentFilter.sortBy,
    );
    widget.onFilterChanged(newFilter);
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      selectedCategoryIds = [];
      final now = DateTime.now();
      selectedYear = now.year;
      selectedMonth = now.month;
      selectedDay = null;
      last30Days = false;
      isInterval = false;
      startYear = null;
      startMonth = null;
      startDay = null;
      endYear = null;
      endMonth = null;
      endDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: widget.categories.map((cat) {
            final isSelected = selectedCategoryIds.contains(cat.id);
            return FilterChip(
              label: Text(cat.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedCategoryIds.add(cat.id);
                  } else {
                    selectedCategoryIds.remove(cat.id);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text('Time Period', style: TextStyle(fontWeight: FontWeight.bold)),
        CheckboxListTile(
          title: const Text('Last 30 days'),
          value: last30Days,
          onChanged: (val) {
            setState(() {
              last30Days = val ?? false;
              if (last30Days) isInterval = false;
            });
          },
        ),
        if (!last30Days)
          CheckboxListTile(
            title: const Text('Custom Interval'),
            value: isInterval,
            onChanged: (val) {
              setState(() {
                isInterval = val ?? false;
              });
            },
          ),
        const SizedBox(height: 8),
        if (!last30Days && !isInterval) _buildSinglePointSelector(),
        if (!last30Days && isInterval) _buildIntervalSelector(),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(onPressed: _reset, child: const Text('Reset')),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(onPressed: _apply, child: const Text('Apply')),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSinglePointSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown<int>(
            hint: 'Year',
            value: selectedYear,
            items: [null, ...List.generate(10, (i) => DateTime.now().year - i)],
            labelBuilder: (y) => y?.toString() ?? 'All Years',
            onChanged: (val) => setState(() => selectedYear = val),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown<int>(
            hint: 'Month',
            value: selectedMonth,
            items: [null, ...List.generate(12, (i) => i + 1)],
            labelBuilder: (m) => m != null ? _monthName(m) : 'All Months',
            onChanged: (val) => setState(() => selectedMonth = val),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown<int>(
            hint: 'Day',
            value: selectedDay,
            items: [null, ...List.generate(31, (i) => i + 1)],
            labelBuilder: (d) => d?.toString() ?? 'All Days',
            onChanged: (val) => setState(() => selectedDay = val),
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalSelector() {
    return Column(
      children: [
        const Text('Start Date', style: TextStyle(fontSize: 12)),
        Row(
          children: [
            Expanded(
              child: _buildDropdown<int>(
                hint: 'Year',
                value: startYear,
                items: [null, ...List.generate(10, (i) => DateTime.now().year - i)],
                labelBuilder: (y) => y?.toString() ?? 'Year',
                onChanged: (val) => setState(() => startYear = val),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildDropdown<int>(
                hint: 'Month',
                value: startMonth,
                items: [null, ...List.generate(12, (i) => i + 1)],
                labelBuilder: (m) => m != null ? _monthName(m) : 'Month',
                onChanged: (val) => setState(() => startMonth = val),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildDropdown<int>(
                hint: 'Day',
                value: startDay,
                items: [null, ...List.generate(31, (i) => i + 1)],
                labelBuilder: (d) => d?.toString() ?? 'Day',
                onChanged: (val) => setState(() => startDay = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('End Date', style: TextStyle(fontSize: 12)),
        Row(
          children: [
            Expanded(
              child: _buildDropdown<int>(
                hint: 'Year',
                value: endYear,
                items: [null, ...List.generate(10, (i) => DateTime.now().year - i)],
                labelBuilder: (y) => y?.toString() ?? 'Year',
                onChanged: (val) => setState(() => endYear = val),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildDropdown<int>(
                hint: 'Month',
                value: endMonth,
                items: [null, ...List.generate(12, (i) => i + 1)],
                labelBuilder: (m) => m != null ? _monthName(m) : 'Month',
                onChanged: (val) => setState(() => endMonth = val),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildDropdown<int>(
                hint: 'Day',
                value: endDay,
                items: [null, ...List.generate(31, (i) => i + 1)],
                labelBuilder: (d) => d?.toString() ?? 'Day',
                onChanged: (val) => setState(() => endDay = val),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T?> items,
    required String Function(T?) labelBuilder,
    required Function(T?) onChanged,
  }) {
    return DropdownButton<T>(
      isExpanded: true,
      hint: Text(hint, style: const TextStyle(fontSize: 12)),
      value: value,
      items: items
          .map(
            (i) => DropdownMenuItem(
              value: i,
              child: Text(labelBuilder(i), style: const TextStyle(fontSize: 12)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  String _monthName(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }
}
