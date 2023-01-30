import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/category/category_state.dart';
import 'package:spending_tracker/common_widgets/my_button.dart';
import 'package:spending_tracker/examples.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var categoryState = context.watch<CategoryState>();
    var categories = categoryState.getEnabledCategories();

    return Center(
      child: ListView.separated(
        itemCount: categories.length,
        separatorBuilder: (BuildContext ctx, int index) => const SizedBox(
          height: 10,
        ),
        itemBuilder: (BuildContext ctx, int index) => MyButton(
          onPressed: () {
            print(categories[index].name);
          },
          text: categories[index].name,
          // onPressed: () => print(categories[index].name),
        ),
        // children: [
        //   for (var category in categories)
        //     ElevatedButton(
        //       child: Text(category.name),
        //       onPressed: () => print(category.name),
        //     )
        // ],
      ),
    );
  }
}
