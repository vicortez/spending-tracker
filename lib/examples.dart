// Example page
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/models/category/category_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<CategoryState>();

    return const Center(child: Text('No favorites yet'));

    // return ListView(
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.all(20),
    //       child: Text('You have ${appState.favorites.length} facorites:'),
    //     ),
    //     for (var current in appState.favorites)
    //       ListTile(
    //         leading: const Icon(Icons.favorite),
    //         title: Text(current),
    //       )
    //   ],
    // );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          text,
        ),
      ),
    );
  }
}
