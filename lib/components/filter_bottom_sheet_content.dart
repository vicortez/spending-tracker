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

  @override
  void initState() {
    super.initState();
    selectedCategoryIds = List.from(widget.currentFilter.categoryIds ?? []);
    selectedYear = widget.currentFilter.year;
    selectedMonth = widget.currentFilter.month;
  }

  void _apply() {
    final newFilter = ExpenseFilter(
      categoryIds: selectedCategoryIds,
      year: selectedYear,
      month: selectedMonth,
      sortBy: widget.currentFilter.sortBy,
      // DateRange filters could be added here if we want range-based UI
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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButton<int>(
                isExpanded: true,
                hint: const Text('Year'),
                value: selectedYear,
                items: [null, ...List.generate(10, (i) => DateTime.now().year - i)]
                    .map(
                      (y) => DropdownMenuItem(value: y, child: Text(y?.toString() ?? 'All Years')),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedYear = val),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButton<int>(
                isExpanded: true,
                hint: const Text('Month'),
                value: selectedMonth,
                items: [null, ...List.generate(12, (i) => i + 1)]
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(m != null ? _monthName(m) : 'All Months'),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedMonth = val),
              ),
            ),
          ],
        ),
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
