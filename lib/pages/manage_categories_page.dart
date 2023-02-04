import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/category/category.dart';
import 'package:spending_tracker/category/category_state.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final _currentCategoryNameTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var categoryState = context.watch<CategoryState>();
    var categories = categoryState.getEnabledCategories();

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
                    controller: _currentCategoryNameTextController,
                    decoration: const InputDecoration(hintText: 'New category'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Category must have a name";
                      }
                      bool isDuplicate =
                          categories.any((cat) => cat.name == value);
                      if (isDuplicate) {
                        return "Category already exists";
                      }
                      return null;
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
            child: ListView(
          children: [
            for (var name in categories.map((cat) => cat.name))
              Card(
                child: ListTile(
                  title: Text(name),
                  trailing: IconButton(
                    onPressed: () {
                      categoryState.removeCategory(name);
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              )
          ],
        ))
      ],
    );
  }

  void submitCategory() {
    String currentText = _currentCategoryNameTextController.text;
    debugPrint(currentText);
    var categoryState = context.read<CategoryState>();
    Category categoryToAdd = Category.name(currentText);
    categoryState.addCategory(categoryToAdd);
    _currentCategoryNameTextController.clear();
  }
}
