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
}

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
