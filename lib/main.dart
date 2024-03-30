import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/common_widgets/month_button.dart';
import 'package:spending_tracker/config/config_name.dart';
import 'package:spending_tracker/config/config_state.dart';
import 'package:spending_tracker/models/category/category_state.dart';
import 'package:spending_tracker/models/domain/domain_state.dart';
import 'package:spending_tracker/models/expense/expense_state.dart';
import 'package:spending_tracker/models/focused_month/focused_month_state.dart';
import 'package:spending_tracker/pages/choose_entity_to_manage_page.dart';
import 'package:spending_tracker/pages/config_page.dart';
import 'package:spending_tracker/pages/home_page.dart';
import 'package:spending_tracker/pages/info_page.dart';
import 'package:spending_tracker/pages/spending_report_page.dart';
import 'package:spending_tracker/translations/translations.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey();
final GlobalKey<NavigatorState> nestedNavigatorKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseState(),
      child: ChangeNotifierProvider(
        create: (context) => CategoryState(),
        child: ChangeNotifierProvider(
          create: (context) => ConfigState(),
          child: ChangeNotifierProvider(
            create: (context) => FocusedMonthState(),
            child: ChangeNotifierProvider(
              create: (context) => DomainState(),
              child: MaterialApp(
                navigatorKey: mainNavigatorKey,
                title: 'Spending tracker',
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: const ColorScheme.dark(primary: Colors.teal),
                  // colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
                ),
                home: const MainPage(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var selectedIndex = 0;
  bool firstLoad = true;

  void loadState() async {
    var categoryState = context.watch<CategoryState>();
    var expenseState = context.watch<ExpenseState>();
    var configState = context.watch<ConfigState>();
    var focusedMonthState = context.watch<FocusedMonthState>();
    var domainState = context.watch<DomainState>();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    categoryState.loadCategoriesFromLocalStorage(prefs);
    expenseState.loadFromLocalStorage(prefs);
    configState.loadFromLocalStorage(prefs);
    focusedMonthState.loadFromLocalStorage(prefs);
    domainState.loadFromLocalStorage(prefs);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstLoad) {
      loadState();
      firstLoad = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRunWelcomeProcedure(context, nestedNavigatorKey, onNext: () {
        setState(() {
          selectedIndex = 1;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    var configState = context.watch<ConfigState>();
    var focusedMonthState = context.watch<FocusedMonthState>();

    switch (selectedIndex) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = ChooseEntityToManagePage(
          navigatorKey: nestedNavigatorKey,
        );
        break;
      case 2:
        page = const SpendingReportPage();
        break;
      case 3:
        page = const ConfigPage();
        break;
      case 4:
        page = const InfoPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex index');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return WillPopScope(
        onWillPop: () async {
          if (nestedNavigatorKey?.currentState != null && nestedNavigatorKey.currentState!.canPop()) {
            nestedNavigatorKey.currentState?.pop(context);
            return false;
          }
          return true;
        },
        child: Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  leading: MonthButton(
                    month: focusedMonthState.getMonth().month,
                    allMonths: configState.getConfig(ConfigName.seeAllMonths),
                    onPressed: () {
                      showMonthPicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1990),
                        lastDate: DateTime(DateTime.now().year + 50),
                      ).then((DateTime? monthDate) {
                        if (monthDate != null) {
                          focusedMonthState.setFocusedMonth(monthDate);
                        }
                      });
                    },
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.label_outline),
                      label: Text('Manage categories'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      label: Text('Spending report'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      label: Text('Settings'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.info_outline),
                      label: Text('About'),
                    ),
                  ],
                  groupAlignment: -.5,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (int value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: SafeArea(
                  child: Container(
                    // we can use Colors.nameofcolor for predefined colors
                    // or we can use Color.fromRGBO(0, 255, 0, 1.0), or Color(0xFF00FF00) for
                    // anonymous colors. It is recommended to set colors in the theme object
                    // instead of using anonymous ones where possible.
                    // we can also use colors from the theme.
                    color: Theme.of(context).colorScheme.background,
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      child: page,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  _checkAndRunWelcomeProcedure(BuildContext context, GlobalKey<NavigatorState> nestedNavigatorKey,
      {required void Function() onNext}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showDialog = (prefs.getBool('isFirstRun') ?? true);

    // if (true) {
    if (showDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog(context, prefs, onNext: onNext);
      });
    }
  }

  _showWelcomeDialog(BuildContext context, SharedPreferences prefs, {required void Function() onNext}) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Welcome!'),
          content: const Text(welcome1),
          actions: <Widget>[
            const Text(
              '1/2',
            ),
            TextButton(
              child: const Text('Next'),
              onPressed: () async {
                Navigator.of(context).pop();
                onNext();
              },
            ),
          ],
        );
      },
    );
  }
}
