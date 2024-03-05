import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/common_widgets/my_button.dart';
import 'package:spending_tracker/models/category/category.dart';
import 'package:spending_tracker/models/category/category_state.dart';
import 'package:spending_tracker/models/expense/expense.dart';
import 'package:spending_tracker/models/expense/expense_state.dart';

class EditExpensePage extends StatefulWidget {
  const EditExpensePage({super.key, required this.expense});

  final Expense expense;

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _expenseAmountTextController = TextEditingController();
  final TextEditingController dateTextController = TextEditingController();
  String categoryName = "";
  int? categoryId;
  DateTime currentDate = DateTime.now();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    categoryName = widget.expense.categoryName;
    categoryId = widget.expense.categoryId;
    RegExp trailingZeroesRegex = RegExp(r'([.]*0)(?!.*\d)');
    _expenseAmountTextController.text = widget.expense.amount.toString().replaceAll(trailingZeroesRegex, '');
    selectedDate = widget.expense.date;
    dateTextController.text = selectedDate.toString().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    var categoryState = context.watch<CategoryState>();
    var expenseState = context.watch<ExpenseState>();
    List<Category> categories = categoryState.getEnabledCategories();

    var options = categories.map((cat) => cat.name);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Edit expense"),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: constraints.copyWith(minHeight: constraints.maxHeight, maxHeight: double.infinity),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      value: options.contains(categoryName) ? categoryName : options.first,
                                      onChanged: (String? selectedOption) {
                                        categoryName = selectedOption!;
                                        categoryId =
                                            categories.firstWhereOrNull((cat) => cat.name == selectedOption)?.id;
                                      },
                                      items: options.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            decoration: const InputDecoration(labelText: "Amount"),
                                            controller: _expenseAmountTextController,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(decimal: true, signed: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp('[0-9.-]+')),
                                            ],
                                            validator: (value) {
                                              double? amount = double.tryParse(_expenseAmountTextController.text);
                                              if (amount == null) {
                                                return "Invalid amount";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: TextFormField(
                                                controller: dateTextController,
                                                decoration: const InputDecoration(
                                                  icon: Icon(Icons.calendar_today_outlined), //icon of text field
                                                ),
                                                readOnly: true,
                                                onTap: () async {
                                                  DateTime? pickedDate = await showDatePicker(
                                                      context: context,
                                                      initialDate: widget.expense.date,
                                                      firstDate: DateTime(1950),
                                                      lastDate: DateTime(currentDate.year + 20));

                                                  if (pickedDate != null) {
                                                    dateTextController.text = pickedDate.toString().substring(0, 10);
                                                    selectedDate = pickedDate;
                                                  }
                                                }))
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                      Expanded(
                          child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: MyButton(
                                      text: "Delete",
                                      onPressed: () {
                                        expenseState.removeExpense(widget.expense.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Expense removed')),
                                        );
                                        Navigator.pop(context);
                                      },
                                      type: ButtonType.danger,
                                    )),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                        child: MyButton(
                                            text: "Save",
                                            onPressed: () {
                                              var amount = double.tryParse(_expenseAmountTextController.text);
                                              bool success = false;
                                              if (amount != null && selectedDate != null) {
                                                success = expenseState.updateExpense(
                                                    widget.expense.id, categoryId, categoryName, amount, selectedDate!);
                                              }
                                              if (success) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Expense updated'),
                                                  ),
                                                );
                                                Navigator.pop(context);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Error updating expense'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            })),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                        child: MyButton(
                                            text: "Back",
                                            onPressed: () {
                                              Navigator.pop(context);
                                            })),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
