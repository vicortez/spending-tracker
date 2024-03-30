import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/common_widgets/my_button.dart';
import 'package:spending_tracker/pages/manage_categories_page.dart';
import 'package:spending_tracker/pages/manage_domains_page.dart';
import 'package:spending_tracker/translations/translations.dart';

class ChooseEntityToManagePage extends StatefulWidget {
  GlobalKey<NavigatorState> navigatorKey;

  ChooseEntityToManagePage({super.key, required this.navigatorKey, bool isFirstRun = false});

  @override
  State<ChooseEntityToManagePage> createState() => _ChooseEntityToManagePageState();
}

class _ChooseEntityToManagePageState extends State<ChooseEntityToManagePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRunWelcomeProcedure(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    double buttonHeight = 60;
    return Navigator(
      key: widget.navigatorKey,
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

  // if we're gonna start showing even more dialogs, refactor to not repeat so much code
  _checkAndRunWelcomeProcedure(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showDialog = (prefs.getBool('isFirstRun') ?? true);

    // if (true) {
    if (showDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog(context, prefs);
      });
    }
  }

  _showWelcomeDialog(BuildContext context, SharedPreferences prefs) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manage Categories and Domains'),
          content: const Text(welcome_categories),
          actions: <Widget>[
            const Text(
              '2/2',
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();
                await prefs.setBool('isFirstRun', false);
              },
            ),
          ],
        );
      },
    );
  }
}
