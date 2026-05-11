import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/utils/toast_utils.dart';

class EditExpenseForm extends StatefulWidget {
  const EditExpenseForm({
    super.key,
    this.expense,
    this.initialCategoryId,
    this.initialCategoryName,
    this.initialAmount,
    this.initialDate,
  });

  final ExpenseEntity? expense;
  final int? initialCategoryId;
  final String? initialCategoryName;
  final String? initialAmount;
  final String? initialDate;

  bool get isEditMode => expense != null;

  @override
  State<EditExpenseForm> createState() => _EditExpenseFormState();
}

class _EditExpenseFormState extends State<EditExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _expenseAmountTextController = TextEditingController();
  final TextEditingController dateTextController = TextEditingController();
  CategoryEntity? relatedCategory;

  DateTime currentDate = DateTime.now();
  DateTime? selectedDate;
  bool _hasBeenTouched = false;

  @override
  void initState() {
    super.initState();

    var categoryState = context.read<CategoryProvider>();

    if (widget.isEditMode) {
      // Edit mode: load from existing expense
      int categoryId = widget.expense!.categoryId;
      relatedCategory = categoryState.getCategories().firstWhereOrNull(
        (element) => element.id == categoryId,
      );

      RegExp trailingZeroesRegex = RegExp(r'([.]*0)(?!.*\d)');
      _expenseAmountTextController.text = widget.expense!.amount.toString().replaceAll(
        trailingZeroesRegex,
        '',
      );
      selectedDate = widget.expense!.date;
      dateTextController.text = selectedDate.toString().substring(0, 10);
    } else {
      // Add mode: use initial values
      if (widget.initialCategoryId != null) {
        relatedCategory = categoryState.getCategories().firstWhereOrNull(
          (element) => element.id == widget.initialCategoryId,
        );
      }

      if (widget.initialAmount != null) {
        _expenseAmountTextController.text = widget.initialAmount!;
        _hasBeenTouched = true; // Pre-filled values count as touched
      }

      if (widget.initialDate != null) {
        dateTextController.text = widget.initialDate!;
        selectedDate = DateTime.parse(widget.initialDate!);
        _hasBeenTouched = true; // Pre-filled values count as touched
      } else {
        selectedDate = currentDate;
        dateTextController.text = selectedDate.toString().substring(0, 10);
      }
    }

    // Add listeners to track if form has been touched
    _expenseAmountTextController.addListener(_markAsTouched);
  }

  void _markAsTouched() {
    if (!_hasBeenTouched) {
      setState(() {
        _hasBeenTouched = true;
      });
    }
  }

  @override
  void dispose() {
    _expenseAmountTextController.removeListener(_markAsTouched);
    _expenseAmountTextController.dispose();
    dateTextController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasBeenTouched) {
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    var categoryProvider = context.watch<CategoryProvider>();
    var expenseProvider = context.watch<ExpenseProvider>();

    List<CategoryEntity> categoryOptions = categoryProvider.getCategories();
    categoryOptions.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return PopScope(
      canPop: !_hasBeenTouched,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<CategoryEntity>(
                      isExpanded: true,
                      initialValue: relatedCategory,
                      onChanged: (CategoryEntity? selectedOption) {
                        relatedCategory = selectedOption;
                        _markAsTouched();
                      },
                      items: categoryOptions.map<DropdownMenuItem<CategoryEntity>>((
                        CategoryEntity value,
                      ) {
                        return DropdownMenuItem<CategoryEntity>(
                          value: value,
                          child: Text(
                            value.name,
                            // overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Amount'),
                      controller: _expenseAmountTextController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.-]+'))],
                      validator: (value) {
                        double? amount = double.tryParse(_expenseAmountTextController.text);
                        if (amount == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: dateTextController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today_outlined),
                        labelText: 'Date',
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? currentDate,
                          firstDate: DateTime(1950),
                          lastDate: DateTime(currentDate.year + 20),
                        );

                        if (pickedDate != null) {
                          dateTextController.text = pickedDate.toString().substring(0, 10);
                          selectedDate = pickedDate;
                          _markAsTouched();
                        }
                      },
                    ),
                  ],
                ),
              ),
              if (widget.isEditMode) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    'Created at: ${widget.expense!.createdAt.toString().substring(0, 16)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (widget.isEditMode) ...[
                CoolButton(
                  text: 'Delete',
                  onPressed: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete expense?'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true && context.mounted) {
                      expenseProvider.removeExpense(widget.expense!.id);
                      showToast(context, 'Expense removed');
                      context.pop();
                    }
                  },
                  type: ButtonType.danger,
                ),
                const SizedBox(height: 24),
              ],
              CoolButton(
                text: 'Save',
                onPressed: () {
                  var amount = double.tryParse(_expenseAmountTextController.text);
                  bool success = false;

                  if (amount != null && selectedDate != null && relatedCategory != null) {
                    if (widget.isEditMode) {
                      // Update existing expense
                      success = expenseProvider.updateExpense(
                        widget.expense!.id,
                        relatedCategory!.id,
                        amount,
                        selectedDate!,
                      );
                    } else {
                      // Add new expense
                      expenseProvider.addExpense(
                        relatedCategory!.id,
                        relatedCategory!.name,
                        amount,
                        date: selectedDate,
                      );
                      success = true;
                    }
                  }

                  if (success) {
                    showToast(context, widget.isEditMode ? 'Expense updated' : 'Expense added');
                    context.pop();
                  } else {
                    showToast(context, 'Error saving expense');
                  }
                },
              ),
              const SizedBox(height: 8),
              CoolButton(
                text: 'Back',
                onPressed: () async {
                  if (_hasBeenTouched) {
                    final shouldPop = await _onWillPop();
                    if (shouldPop && context.mounted) {
                      context.pop();
                    }
                  } else {
                    context.pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
