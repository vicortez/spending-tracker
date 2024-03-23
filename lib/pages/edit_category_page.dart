import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/common_widgets/my_button.dart';
import 'package:spending_tracker/models/category/category.dart';
import 'package:spending_tracker/models/category/category_state.dart';
import 'package:spending_tracker/models/domain/domain.dart';
import 'package:spending_tracker/models/domain/domain_state.dart';

import '../models/expense/expense_state.dart';

class EditCategoryPage extends StatefulWidget {
  final Category category;

  const EditCategoryPage({super.key, required this.category});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    RegExp trailingZeroesRegex = RegExp(r'([.]*0)(?!.*\d)');
    _categoryNameTextController.text = widget.category.name;
  }

  @override
  Widget build(BuildContext context) {
    var categoryState = context.watch<CategoryState>();
    var domainState = context.watch<DomainState>();
    var expenseState = context.watch<ExpenseState>();

    var scaffoldMessenger = ScaffoldMessenger.of(context);

    List<Domain> domains = domainState.domains;
    List<Domain?> domainOptions = [null, ...domains];
    Domain? domainFromCategory = domains.firstWhereOrNull((domain) => domain.id == widget.category.domainId);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Edit category"),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            decoration: const InputDecoration(labelText: "Name"),
                                            controller: _categoryNameTextController,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return "invalid name";
                                              }
                                              var newNameClashesWithExisting = value != widget.category.name &&
                                                  categoryState.existsCategoryWithName(value);
                                              if (newNameClashesWithExisting) {
                                                return "name already exists";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    DropdownButtonFormField<Domain?>(
                                      disabledHint: const Text("No domains to choose from"),
                                      iconDisabledColor: Colors.grey.withOpacity(0.5),
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(0, 5.5, 0, 0),
                                          labelStyle: TextStyle(),
                                          labelText: 'Domain'),
                                      value: domainOptions.firstWhereOrNull((element) => element == domainFromCategory),
                                      onChanged: domains.isNotEmpty
                                          ? (Domain? selectedDomain) {
                                              domainFromCategory = selectedDomain;
                                            }
                                          : null,
                                      items: domainOptions.map<DropdownMenuItem<Domain?>>((Domain? value) {
                                        return DropdownMenuItem<Domain?>(
                                          value: value,
                                          child: Text(
                                            value?.name ?? "<no domain>",
                                          ),
                                        );
                                      }).toList(),
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
                                        if (canRemoveCategory(widget.category.id, expenseState)) {
                                          categoryState.removeCategory(widget.category.id);
                                          scaffoldMessenger.showSnackBar(
                                            const SnackBar(content: Text('Category removed')),
                                          );
                                          Navigator.pop(context);
                                        } else {
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                                content: Container(
                                                    child: Row(
                                              children: [
                                                const Expanded(
                                                    child: Text('Can\'t delete category. Delete expenses using it')),
                                                IconButton(
                                                    onPressed: () {
                                                      scaffoldMessenger.hideCurrentSnackBar();
                                                    },
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ))
                                              ],
                                            ))),
                                          );
                                        }
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
                                              if (!_formKey.currentState!.validate()) {
                                                return;
                                              }
                                              String newCatName = _categoryNameTextController.text;
                                              int catId = widget.category.id;
                                              bool success = categoryState.updateCategory(
                                                  catId, newCatName, domainFromCategory?.id);
                                              if (success) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Category updated'),
                                                  ),
                                                );
                                                Navigator.pop(context);
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

  bool canRemoveCategory(int catId, ExpenseState expenseState) {
    return !expenseState.existsExpenseForCategory(catId);
  }
}
