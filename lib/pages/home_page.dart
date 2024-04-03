import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/common_widgets/my_button.dart';
import 'package:spending_tracker/models/category/category_state.dart';
import 'package:spending_tracker/models/domain/domain.dart';
import 'package:spending_tracker/models/expense/expense_state.dart';

import '../models/category/category.dart';
import '../models/domain/domain_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final expenseAmountTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var categoryState = context.watch<CategoryState>();
    var domainState = context.watch<DomainState>();

    List<Category> categories = categoryState.getCategories();
    List<Domain> domains = domainState.domains;

    domains.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    LinkedHashMap<Domain?, List<Category>> catByDomain = LinkedHashMap();

    for (Domain domain in domains) {
      List<Category> foundCategories = categories.where((cat) => cat.domainId == domain.id).toList();
      if (foundCategories.isNotEmpty) {
        catByDomain[domain] = foundCategories;
      }
    }
    List<Category> noDomainCategories = categories.where((cat) => cat.domainId == null).toList();
    if (noDomainCategories.isNotEmpty) {
      catByDomain[null] = noDomainCategories;
    }

    return Center(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
                itemCount: catByDomain.length,
                separatorBuilder: (BuildContext ctx, int index) => const SizedBox(
                      height: 15,
                    ),
                itemBuilder: (context, index) {
                  Domain? domain = catByDomain.keys.elementAtOrNull(index);
                  String domainLabel = "Categories with no domain";
                  if (domain?.name != null && domain!.name.isNotEmpty) {
                    domainLabel = domain!.name;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      ),
                      Text(domainLabel, style: Theme.of(context).textTheme.titleMedium),
                      ListView.separated(
                        itemBuilder: (context, index2) {
                          var category = catByDomain[domain]![index2];
                          return MyButton(
                            text: category.name,
                            onPressed: () {
                              handleSubmitExpense(category.id, category.name, expenseAmountTextController.text);
                            },
                          );
                        },
                        separatorBuilder: (BuildContext ctx, int index) => const SizedBox(
                          height: 10,
                        ),
                        itemCount: catByDomain[domain]!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                      )
                    ],
                  );
                }),
          ),
          TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: '💸 Register expense'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              controller: expenseAmountTextController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.-]+')),
              ]),
        ],
      ),
    );
  }

  void handleSubmitExpense(int categoryId, String categoryName, String text) {
    double? amount = double.tryParse(text);
    if (amount == null || categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid expense'),
        ),
      );
    } else {
      var expenseState = context.read<ExpenseState>();
      expenseState.addExpense(categoryId, categoryName, amount);
      expenseAmountTextController.clear();
    }
  }
}
