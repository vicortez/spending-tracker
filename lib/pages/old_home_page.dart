import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/examples.dart';
import 'package:spending_tracker/models/category/category_state.dart';

class OldHomePage extends StatelessWidget {
  const OldHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var catState = context.watch<CategoryState>();
    var currentValue = "asdf";

    IconData icon;
    if (true) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Olás"),
          BigCard(text: currentValue),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  // appState.genNext();
                },
                child: const Text('Next'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              catState.addCategory("name");
            },
            child: const Text('add cat'),
          ),
        ],
      ),
    );
  }
}
