import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/utils/toast_utils.dart';

class EditCategoryPage extends StatefulWidget {
  final CategoryEntity category;

  const EditCategoryPage({super.key, required this.category});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameTextController = TextEditingController();
  bool? catIsEnabled;

  @override
  void initState() {
    super.initState();

    RegExp trailingZeroesRegex = RegExp(r'([.]*0)(?!.*\d)');
    _categoryNameTextController.text = widget.category.name;
    catIsEnabled = widget.category.enabled;
  }

  @override
  Widget build(BuildContext context) {
    var categoryProvider = context.watch<CategoryProvider>();
    var domainProvider = context.watch<DomainProvider>();
    var expenseProvider = context.watch<ExpenseProvider>();

    var scaffoldMessenger = ScaffoldMessenger.of(context);

    List<DomainEntity> domains = domainProvider.domains;
    List<DomainEntity?> domainOptions = [null, ...domains];
    DomainEntity? domainFromCategory = domains.firstWhereOrNull(
      (domain) => domain.id == widget.category.domainId,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit category')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: constraints.copyWith(
                minHeight: constraints.maxHeight,
                maxHeight: double.infinity,
              ),
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
                                        decoration: const InputDecoration(labelText: 'Name'),
                                        controller: _categoryNameTextController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'invalid name';
                                          }
                                          var newNameClashesWithExisting =
                                              value != widget.category.name &&
                                              categoryProvider.existsCategoryWithName(value);
                                          if (newNameClashesWithExisting) {
                                            return 'name already exists';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                DropdownButtonFormField<DomainEntity?>(
                                  disabledHint: const Text('No domains to choose from'),
                                  iconDisabledColor: Colors.grey.withOpacity(0.5),
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.fromLTRB(0, 5.5, 0, 0),
                                    labelStyle: TextStyle(),
                                    labelText: 'Domain',
                                  ),
                                  initialValue: domainOptions.firstWhereOrNull(
                                    (element) => element == domainFromCategory,
                                  ),
                                  onChanged: domains.isNotEmpty
                                      ? (DomainEntity? selectedDomain) {
                                          domainFromCategory = selectedDomain;
                                        }
                                      : null,
                                  items: domainOptions.map<DropdownMenuItem<DomainEntity?>>((
                                    DomainEntity? value,
                                  ) {
                                    return DropdownMenuItem<DomainEntity?>(
                                      value: value,
                                      child: Text(value?.name ?? '<no domain>'),
                                    );
                                  }).toList(),
                                ),
                                CheckboxListTile(
                                  title: const Text('Enabled'),
                                  value: catIsEnabled,
                                  onChanged: (newValue) {
                                    setState(() {
                                      catIsEnabled = newValue;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
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
                                      child: CoolButton(
                                        text: 'Delete',
                                        onPressed: () async {
                                          if (canRemoveCategory(
                                            widget.category.id,
                                            expenseProvider,
                                          )) {
                                            await categoryProvider.removeCategory(
                                              widget.category.id,
                                            );
                                            if (context.mounted) {
                                              showToast(context, 'Category removed');
                                              Navigator.pop(context);
                                            }
                                          } else {
                                            showToast(
                                              context,
                                              'Can\'t delete category. Delete expenses using it',
                                              duration: const Duration(seconds: 4),
                                            );
                                          }
                                        },
                                        type: ButtonType.danger,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CoolButton(
                                        text: 'Save',
                                        onPressed: () async {
                                          if (!_formKey.currentState!.validate()) {
                                            return;
                                          }
                                          String newCatName = _categoryNameTextController.text;
                                          int catId = widget.category.id;
                                          bool success = await categoryProvider.updateCategory(
                                            catId,
                                            newCatName,
                                            domainFromCategory?.id,
                                            catIsEnabled,
                                          );
                                          if (success && context.mounted) {
                                            showToast(context, 'Category updated');
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CoolButton(
                                        text: 'Back',
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool canRemoveCategory(int catId, ExpenseProvider expenseProvider) {
    return !expenseProvider.existsExpenseForCategory(catId);
  }
}
