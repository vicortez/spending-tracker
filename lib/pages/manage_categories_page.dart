import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/models/category/category_state.dart';
import 'package:spending_tracker/models/expense/expense_state.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final _currentCategoryNameTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FocusNode myFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var categoryState = context.watch<CategoryState>();
    var expenseState = context.watch<ExpenseState>();

    var categories = categoryState.getEnabledCategories();
    categories.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Form(
          key: _formKey,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    controller: _currentCategoryNameTextController,
                    decoration: const InputDecoration(hintText: 'New category'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Category must have a name";
                      }
                      bool isDuplicate = categories.any((cat) => cat.name == value);
                      if (isDuplicate) {
                        return "Category already exists";
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      if (_formKey.currentState!.validate()) {
                        submitCategory();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Category added')),
                        );
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitCategory();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Category added')),
                    );
                  }
                },
                icon: const Icon(Icons.add_outlined),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: SelectionArea(
          child: ListView(
            children: [
              for (var name in categories.map((cat) => cat.name))
                Card(
                  child: ListTile(
                    title: Text(name),
                    trailing: IconButton(
                      onPressed: () {
                        if (canRemoveCategory(name, expenseState)) {
                          categoryState.removeCategory(name);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Can\'t delete category. Delete expenses using it')),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                )
            ],
          ),
        ))
      ],
    );
  }

  void submitCategory() {
    String currentText = _currentCategoryNameTextController.text;
    var categoryState = context.read<CategoryState>();
    categoryState.addCategory(currentText);
    _currentCategoryNameTextController.clear();
    myFocusNode.requestFocus();
  }

  bool canRemoveCategory(String catName, ExpenseState expenseState) {
    return !expenseState.existsExpenseForCategory(catName);
  }
}
