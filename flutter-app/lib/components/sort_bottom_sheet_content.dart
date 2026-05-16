import 'package:flutter/material.dart';
import 'package:spending_tracker/components/ui/boring_button.dart';
import 'package:spending_tracker/repository/expense/expense_filter.dart';

class SortBottomSheetContent extends StatefulWidget {
  final List<SortCriteria> currentSortBy;
  final Function(List<SortCriteria>) onSortChanged;

  const SortBottomSheetContent({
    super.key,
    required this.currentSortBy,
    required this.onSortChanged,
  });

  @override
  State<SortBottomSheetContent> createState() => _SortBottomSheetContentState();
}

class _SortBottomSheetContentState extends State<SortBottomSheetContent> {
  late List<SortCriteria> criteriaList;

  @override
  void initState() {
    super.initState();
    criteriaList = List.from(widget.currentSortBy);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = criteriaList.removeAt(oldIndex);
      criteriaList.insert(newIndex, item);
      widget.onSortChanged(criteriaList);
    });
  }

  void _toggleOrder(int index) {
    setState(() {
      final old = criteriaList[index];
      criteriaList[index] = SortCriteria(
        field: old.field,
        order: old.order == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending,
      );
      widget.onSortChanged(criteriaList);
    });
  }

  void _removeCriteria(int index) {
    setState(() {
      criteriaList.removeAt(index);
      widget.onSortChanged(criteriaList);
    });
  }

  void _addCriteria(SortField field) {
    setState(() {
      criteriaList.add(SortCriteria(field: field, order: SortOrder.ascending));
      widget.onSortChanged(criteriaList);
    });
    Navigator.of(context).pop(); // Close the menu
  }

  String _getFieldName(SortField field) {
    switch (field) {
      case SortField.createdAt:
        return 'Creation Date';
      case SortField.expenseDate:
        return 'Date';
      case SortField.domainName:
        return 'Domain Name';
      case SortField.categoryName:
        return 'Category Name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (criteriaList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No sorting applied'),
          )
        else
          SizedBox(
            height: criteriaList.length * 64.0, // Approximate height
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              // Disable default drag handles
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: criteriaList.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final criteria = criteriaList[index];
                return ListTile(
                  key: ValueKey(criteria.field.toString() + index.toString()),
                  title: Text(_getFieldName(criteria.field)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 80,
                        child: BoringButton(
                          text: criteria.order == SortOrder.ascending ? 'ASC' : 'DESC',
                          onPressed: () => _toggleOrder(index),
                          type: BoringButtonType.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => _removeCriteria(index),
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red[300],
                      ),
                      const SizedBox(width: 8),
                      ReorderableDragStartListener(
                        index: index,
                        child: const MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.drag_indicator),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        Center(
          child: IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 32),
            onPressed: () => _showAddFieldMenu(context),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showAddFieldMenu(BuildContext context) {
    final availableFields = SortField.values
        .where((f) => !criteriaList.any((c) => c.field == f))
        .toList();

    if (availableFields.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All sorting fields already added')));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableFields.map((field) {
              return ListTile(title: Text(_getFieldName(field)), onTap: () => _addCriteria(field));
            }).toList(),
          ),
        );
      },
    );
  }
}
