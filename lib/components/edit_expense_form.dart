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

class EditExpenseForm extends StatefulWidget {
  const EditExpenseForm({super.key, required this.expense});

  final ExpenseEntity expense;

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

  @override
  void initState() {
    super.initState();

    int categoryId = widget.expense.categoryId;
    var categoryState = context.read<CategoryProvider>();
    relatedCategory = categoryState.getCategories().firstWhereOrNull(
      (element) => element.id == categoryId,
    );

    RegExp trailingZeroesRegex = RegExp(r'([.]*0)(?!.*\d)');
    _expenseAmountTextController.text = widget.expense.amount.toString().replaceAll(
      trailingZeroesRegex,
      '',
    );
    selectedDate = widget.expense.date;
    dateTextController.text = selectedDate.toString().substring(0, 10);
  }

  @override
  void dispose() {
    _expenseAmountTextController.dispose();
    dateTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var categoryProvider = context.watch<CategoryProvider>();
    var expenseProvider = context.watch<ExpenseProvider>();

    List<CategoryEntity> categoryOptions = categoryProvider.getCategories();
    categoryOptions.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return IntrinsicHeight(
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
                        initialDate: widget.expense.date,
                        firstDate: DateTime(1950),
                        lastDate: DateTime(currentDate.year + 20),
                      );

                      if (pickedDate != null) {
                        dateTextController.text = pickedDate.toString().substring(0, 10);
                        selectedDate = pickedDate;
                      }
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            CoolButton(
              text: 'Delete',
              onPressed: () {
                expenseProvider.removeExpense(widget.expense.id);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Expense removed')));
                context.pop();
              },
              type: ButtonType.danger,
            ),
            const SizedBox(height: 24),
            CoolButton(
              text: 'Save',
              onPressed: () {
                var amount = double.tryParse(_expenseAmountTextController.text);
                bool success = false;
                if (amount != null && selectedDate != null && relatedCategory != null) {
                  success = expenseProvider.updateExpense(
                    widget.expense.id,
                    relatedCategory!.id,
                    amount,
                    selectedDate!,
                  );
                }
                if (success) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Expense updated')));
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error updating expense'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            CoolButton(
              text: 'Back',
              onPressed: () {
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
