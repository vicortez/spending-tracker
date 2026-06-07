import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/main.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/onboarding/onboarding_provider.dart';
import 'package:spending_tracker/repository/settings/settings_provider.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';

void main() {
  group('Add Expense Flow Integration Tests', () {
    late CategoryProvider categoryProvider;
    late DomainProvider domainProvider;
    late ExpenseProvider expenseProvider;
    late SettingsProvider settingsProvider;
    late OnboardingProvider onboardingProvider;
    late NavigationHistoryService navigationHistoryService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      categoryProvider = CategoryProvider();
      domainProvider = DomainProvider();
      expenseProvider = ExpenseProvider();
      settingsProvider = SettingsProvider();
      onboardingProvider = OnboardingProvider();
      navigationHistoryService = NavigationHistoryService();

      await categoryProvider.loadFromLocalStorage(prefs);
      await domainProvider.loadFromLocalStorage(prefs);
      await expenseProvider.loadFromLocalStorage(prefs);
      await settingsProvider.loadFromLocalStorage(prefs);
      await onboardingProvider.init(prefs);
    });

    testWidgets('Complete flow: Add Domain -> Add Category -> Add Expense', (
      WidgetTester tester,
    ) async {
      // 1. Build app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
            ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
            ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 2. Add Domain
      await domainProvider.addDomain('Personal');
      final testDomain = domainProvider.domains[0];

      // 3. Add Category
      await categoryProvider.addCategory('Food');
      final categoryId = categoryProvider.getCategories()[0].id;
      await categoryProvider.updateCategory(categoryId, 'Food', testDomain.id, true);
      final testCategory = categoryProvider.getCategories()[0];

      await tester.pumpAndSettle();

      // 4. Verify category button exists on Home
      expect(find.text('Food'), findsOneWidget);

      // 5. Input amount and tap category
      await tester.enterText(find.byType(TextField), '45.50');
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // 6. Verify expense added
      expect(expenseProvider.expenses.length, 1);
      expect(expenseProvider.expenses[0].amount, 45.50);
      expect(expenseProvider.expenses[0].categoryId, testCategory.id);
    });

    testWidgets('Add expense with custom date via bottom sheet', (WidgetTester tester) async {
      // Setup data
      final testDomain = DomainEntity(id: 1, name: 'Personal');
      await domainProvider.set([testDomain], syncStorage: false);
      final testCategory = CategoryEntity(id: 1, name: 'Food', enabled: true, domainId: 1);
      await categoryProvider.set([testCategory], syncStorage: false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
            ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
            ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Long press category button to open bottom sheet
      await tester.longPress(find.text('Food'));
      await tester.pumpAndSettle();

      // Verify bottom sheet open
      expect(find.text('Add Expense'), findsOneWidget);

      // Enter amount
      await tester.enterText(find.byType(TextFormField).first, '12.34');

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify added
      expect(expenseProvider.expenses.length, 1);
      expect(expenseProvider.expenses[0].amount, 12.34);
    });

    testWidgets('Validation: Cannot add invalid expense amount', (WidgetTester tester) async {
      final testCategory = CategoryEntity(id: 1, name: 'Food', enabled: true);
      await categoryProvider.set([testCategory], syncStorage: false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
            ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
            ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Input invalid text
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();

      // Verify NO expense added
      expect(expenseProvider.expenses.length, 0);
      expect(find.text('Invalid expense'), findsOneWidget);
    });

    testWidgets('Expense count persists across simulated restarts', (WidgetTester tester) async {
      // 1. Add data
      await categoryProvider.addCategory('Food');
      await expenseProvider.addExpense(1, 'Food', 100.0);

      // 2. "Restart" - create new providers using same prefs
      final newExpenseProvider = ExpenseProvider();
      await newExpenseProvider.loadFromLocalStorage(prefs);

      expect(newExpenseProvider.expenses.length, 1);

      // 3. Build app with new provider
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: newExpenseProvider),
            ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
            ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
            ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
            ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsOneWidget);
    });
    group('Add Expense Flow Integration Tests - Specific edge cases', () {
      testWidgets('Quick tap handles concurrency safely', (WidgetTester tester) async {
        final testCategory = CategoryEntity(id: 1, name: 'Food', enabled: true);
        await categoryProvider.set([testCategory], syncStorage: false);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
              ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
              ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
              ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
              ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
              ChangeNotifierProvider<NavigationHistoryService>.value(
                value: navigationHistoryService,
              ),
            ],
            child: const MyApp(),
          ),
        );
        await tester.pumpAndSettle();

        // Enter amount
        await tester.enterText(find.byType(TextField), '10');

        // Rapidly tap the category button 3 times
        // Note: In real life this might be limited by UI responsiveness,
        // but we test the provider's ability to queue saves.
        await tester.tap(find.text('Food'));
        await tester.tap(find.text('Food'));
        await tester.tap(find.text('Food'));

        await tester.pumpAndSettle();

        expect(expenseProvider.expenses.length, 3);
      });
    });
  });
}
