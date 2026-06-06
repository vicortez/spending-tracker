import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/config/config_name.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/onboarding/onboarding_provider.dart';
import 'package:spending_tracker/repository/services/auth_provider.dart';
import 'package:spending_tracker/router/app_router.dart';
import 'package:spending_tracker/services/backup_service.dart';
import 'package:spending_tracker/services/logger_service.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';
import 'package:spending_tracker/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Initialize services
  await LoggerService.init(prefs);
  await BackupService().runDailyBackup(prefs);

  final providers = await loadStores(prefs);

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<ConfigProvider>();
    final themeConfig = configProvider.getConfig(ConfigName.theme);

    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Spending Tracker',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: AppTheme.getThemeMode(themeConfig),
    );
  }
}

Future<List<SingleChildWidget>> loadStores(SharedPreferences prefs) async {
  final expenseProvider = ExpenseProvider();
  final categoryProvider = CategoryProvider();
  final configProvider = ConfigProvider();
  final domainProvider = DomainProvider();
  final authProvider = AuthProvider();
  final onboardingProvider = OnboardingProvider();

  await Future.wait([
    expenseProvider.loadFromLocalStorage(prefs),
    categoryProvider.loadFromLocalStorage(prefs),
    configProvider.loadFromLocalStorage(prefs),
    domainProvider.loadFromLocalStorage(prefs),
    authProvider.loadFromLocalStorage(prefs),
    onboardingProvider.init(prefs),
  ]);

  return [
    ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
    ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
    ChangeNotifierProvider<ConfigProvider>.value(value: configProvider),
    ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
    ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
    ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
    ChangeNotifierProvider<NavigationHistoryService>(create: (ctx) => NavigationHistoryService()),
  ];
}
