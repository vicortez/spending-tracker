import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/main.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/onboarding/onboarding_provider.dart';
import 'package:spending_tracker/repository/services/auth_provider.dart';
import 'package:spending_tracker/repository/settings/settings_provider.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';

void main() {
  group('Import/Export Widget Integration Tests', () {
    testWidgets('Navigate to settings and test export button exists', (WidgetTester tester) async {
      // 1. Initialize Mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'isFirstRun': false,
        'expenses': '[]',
        'categories': '[]',
        'domains': '[]',
        'config': '{}',
      });

      final categoryProvider = CategoryProvider();
      final expenseProvider = ExpenseProvider();
      final settingsProvider = SettingsProvider();
      final domainProvider = DomainProvider();
      final onboardingProvider = OnboardingProvider();
      final authProvider = AuthProvider();
      final navigationHistoryService = NavigationHistoryService();

      final prefs = await SharedPreferences.getInstance();
      await categoryProvider.loadFromLocalStorage(prefs);
      await expenseProvider.loadFromLocalStorage(prefs);
      await domainProvider.loadFromLocalStorage(prefs);
      await settingsProvider.loadFromLocalStorage(prefs);
      await onboardingProvider.init(prefs);
      await authProvider.loadFromLocalStorage(prefs);

      // 2. Add some test data
      await categoryProvider.addCategory('Food');
      await expenseProvider.addExpense(1, 'Food', 50.0);

      // 3. Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
            ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 4. Navigate to Settings page
      final settingsTab = find.byIcon(Icons.settings_outlined);
      expect(settingsTab, findsOneWidget);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // 5. Verify settings page elements
      expect(find.text('Export all app data'), findsOneWidget);
      expect(find.text('Import app data'), findsOneWidget);
      expect(find.text('Export to sheet (excel)'), findsOneWidget);
    });

    testWidgets('Import dialog shows and continue button works', (WidgetTester tester) async {
      // 1. Initialize Mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'isFirstRun': false,
        'expenses': '[]',
        'categories': '[]',
        'domains': '[]',
        'config': '{}',
      });

      final categoryProvider = CategoryProvider();
      final expenseProvider = ExpenseProvider();
      final settingsProvider = SettingsProvider();
      final domainProvider = DomainProvider();
      final onboardingProvider = OnboardingProvider();
      final authProvider = AuthProvider();
      final navigationHistoryService = NavigationHistoryService();

      final prefs = await SharedPreferences.getInstance();
      await categoryProvider.loadFromLocalStorage(prefs);
      await expenseProvider.loadFromLocalStorage(prefs);
      await domainProvider.loadFromLocalStorage(prefs);
      await settingsProvider.loadFromLocalStorage(prefs);
      await onboardingProvider.init(prefs);
      await authProvider.loadFromLocalStorage(prefs);

      // 2. Add some test data
      await categoryProvider.addCategory('Food');
      await expenseProvider.addExpense(1, 'Food', 50.0);

      // 3. Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
            ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 4. Navigate to Settings page
      final settingsTab = find.byIcon(Icons.settings_outlined);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // 5. Tap Import app data button
      final importButton = find.text('Import app data');
      expect(importButton, findsOneWidget);
      await tester.tap(importButton);
      await tester.pumpAndSettle();

      // 6. Verify confirm dialog appears
      expect(find.text('Confirm'), findsOneWidget);
      expect(
        find.text('Importing app data will erase any current app data, and load the new one.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // 7. Tap Continue button - this should NOT crash
      final continueButton = find.text('Continue');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // 8. Dialog should be dismissed
      expect(find.text('Confirm'), findsNothing);
    });

    testWidgets('Delete all expenses button works correctly', (WidgetTester tester) async {
      // 1. Initialize Mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'isFirstRun': false,
        'expenses': '[]',
        'categories': '[]',
        'domains': '[]',
        'config': '{}',
      });

      final categoryProvider = CategoryProvider();
      final expenseProvider = ExpenseProvider();
      final settingsProvider = SettingsProvider();
      final domainProvider = DomainProvider();
      final onboardingProvider = OnboardingProvider();
      final authProvider = AuthProvider();
      final navigationHistoryService = NavigationHistoryService();

      final prefs = await SharedPreferences.getInstance();
      await categoryProvider.loadFromLocalStorage(prefs);
      await expenseProvider.loadFromLocalStorage(prefs);
      await domainProvider.loadFromLocalStorage(prefs);
      await settingsProvider.loadFromLocalStorage(prefs);
      await onboardingProvider.init(prefs);
      await authProvider.loadFromLocalStorage(prefs);

      // 2. Add test data
      await categoryProvider.addCategory('Food');
      await expenseProvider.addExpense(1, 'Food', 50.0);
      await expenseProvider.addExpense(1, 'Food', 75.0);

      expect(expenseProvider.expenses.length, 2);

      // 3. Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
            ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 4. Navigate to Settings page
      final settingsTab = find.byIcon(Icons.settings_outlined);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // 5. Tap Delete all expenses button
      final deleteButton = find.text('DELETE ALL EXPENSES');
      expect(deleteButton, findsOneWidget);
      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // 6. Verify expenses were deleted
      expect(expenseProvider.expenses.length, 0);

      // 7. Verify toast appeared (or rather no crash occurred)
    });
  });
}
