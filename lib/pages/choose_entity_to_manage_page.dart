import 'package:flutter/material.dart';
import 'package:spending_tracker/common_widgets/my_button.dart';
import 'package:spending_tracker/pages/manage_categories_page.dart';
import 'package:spending_tracker/pages/manage_domains_page.dart';

class ChooseEntityToManagePage extends StatelessWidget {
  GlobalKey<NavigatorState> navigatorKey;

  ChooseEntityToManagePage({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    double buttonHeight = 60;
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text("Select entity to manage"),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: buttonHeight,
                        child: MyButton(
                          text: 'Manage Categories',
                          type: ButtonType.normal,
                          onPressed: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => const ManageCategoriesPage()));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: buttonHeight,
                        child: MyButton(
                          text: 'Manage Domains',
                          type: ButtonType.normal,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageDomainsPage()));
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
