import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/pages/edit_category_page.dart';
import 'package:spending_tracker/repository/category/category_state.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_state.dart';

import '../repository/category/category.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

// could have passed most of this to a generic "textual form" component
class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final _currentCategoryNameTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  FocusNode myFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var categoryState = context.watch<CategoryState>();
    var domainState = context.watch<DomainState>();

    var categories = categoryState.getCategories(enabledOnly: false);
    List<DomainEntity> domains = domainState.domains;
    domains.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    LinkedHashMap<DomainEntity, List<CategoryEntity>> catByDomain = LinkedHashMap();

    for (DomainEntity domain in domains) {
      List<CategoryEntity> foundCategories = categories.where((cat) => cat.domainId == domain.id).toList();
      if (foundCategories.isNotEmpty) {
        catByDomain[domain] = foundCategories;
      }
    }
    List<CategoryEntity> noDomainCategories = categories.where((cat) => cat.domainId == null).toList();
    if (noDomainCategories.isNotEmpty) {
      catByDomain[DomainEntity(id: -1, name: "")] = noDomainCategories;
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false; // Prevents the automatic pop of the current
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text("Manage categories"),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Column(
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
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        focusNode: myFocusNode,
                        controller: _currentCategoryNameTextController,
                        decoration: const InputDecoration(hintText: 'New category'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Category must have a name";
                          }
                          bool isDuplicate = categoryState.existsCategoryWithName(value);
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
                            myFocusNode.requestFocus();
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
              child: ListView.builder(
                  itemCount: catByDomain.keys.length,
                  itemBuilder: (context, index) {
                    DomainEntity domain = catByDomain.keys.elementAt(index);
                    return SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          Text(domain.name.isNotEmpty ? domain.name : "Categories with no domain",
                              style: Theme.of(context).textTheme.titleMedium),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: catByDomain[domain]!.length,
                            itemBuilder: (context, index2) {
                              CategoryEntity category = catByDomain[domain]![index2];
                              var color = category.enabled ? Colors.white : Colors.grey;

                              return Card(
                                child: ListTile(
                                  title: Text(
                                    category.name,
                                    style: TextStyle(color: color),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EditCategoryPage(category: category)));
                                    },
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          )
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void submitCategory() {
    String currentText = _currentCategoryNameTextController.text;
    var categoryState = context.read<CategoryState>();
    categoryState.addCategory(currentText);
    _currentCategoryNameTextController.clear();
  }
}
