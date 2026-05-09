import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/focused_month/focused_month_provider.dart';
import 'package:spending_tracker/repository/onboarding/onboarding_provider.dart';
import 'package:spending_tracker/router/app_router.dart';
import 'package:spending_tracker/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MultiProvider(providers: initializeGlobalProviders(prefs), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Spending Tracker',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
    );
  }
}

List<SingleChildWidget> initializeGlobalProviders(SharedPreferences prefs) {
  return [
    ChangeNotifierProvider(create: (ctx) => ExpenseProvider()..loadFromLocalStorage(prefs)),
    ChangeNotifierProvider(
      create: (ctx) => CategoryProvider()..loadCategoriesFromLocalStorage(prefs),
    ),
    ChangeNotifierProvider(create: (ctx) => ConfigProvider()..loadFromLocalStorage(prefs)),
    ChangeNotifierProvider(create: (ctx) => FocusedMonthProvider()..loadFromLocalStorage(prefs)),
    ChangeNotifierProvider(create: (ctx) => DomainProvider()..loadFromLocalStorage(prefs)),
    ChangeNotifierProvider(create: (ctx) => OnboardingProvider()..init(prefs)),
  ];
}
