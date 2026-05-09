import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final expenseAmountTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var categoryProvider = context.watch<CategoryProvider>();
    var domainProvider = context.watch<DomainProvider>();

    List<CategoryEntity> categories = categoryProvider.getCategories();
    List<DomainEntity> domains = domainProvider.domains;

    domains.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    LinkedHashMap<DomainEntity?, List<CategoryEntity>> catByDomain = LinkedHashMap();

    for (DomainEntity domain in domains) {
      List<CategoryEntity> foundCategories = categories
          .where((cat) => cat.domainId == domain.id)
          .toList();
      if (foundCategories.isNotEmpty) {
        catByDomain[domain] = foundCategories;
      }
    }
    List<CategoryEntity> noDomainCategories = categories
        .where((cat) => cat.domainId == null)
        .toList();
    if (noDomainCategories.isNotEmpty) {
      catByDomain[null] = noDomainCategories;
    }

    return Center(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: catByDomain.length,
              separatorBuilder: (BuildContext ctx, int index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                DomainEntity? domain = catByDomain.keys.elementAtOrNull(index);
                String domainLabel = 'Categories with no domain';
                if (domain?.name != null && domain!.name.isNotEmpty) {
                  domainLabel = domain.name;
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                    Text(domainLabel, style: Theme.of(context).textTheme.titleMedium),
                    ListView.separated(
                      itemBuilder: (context, index2) {
                        var category = catByDomain[domain]![index2];
                        return CoolButton(
                          text: category.name,
                          onPressed: () {
                            handleSubmitExpense(
                              category.id,
                              category.name,
                              expenseAmountTextController.text,
                            );
                          },
                          type: ButtonType.theme,
                          outline: true,
                          baseColor: Colors.grey[900],
                          // baseColor: Colors.teal[900],
                          textColor: Colors.teal,
                        );
                      },
                      separatorBuilder: (BuildContext ctx, int index) => const SizedBox(height: 6),
                      itemCount: catByDomain[domain]!.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  ],
                );
              },
            ),
          ),
          TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: '💸 Register expense'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            controller: expenseAmountTextController,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.-]+'))],
          ),
        ],
      ),
    );
  }

  void handleSubmitExpense(int categoryId, String categoryName, String text) {
    double? amount = double.tryParse(text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid expense')));
    } else {
      var expenseProvider = context.read<ExpenseProvider>();
      expenseProvider.addExpense(categoryId, categoryName, amount);
      expenseAmountTextController.clear();
    }
  }
}
