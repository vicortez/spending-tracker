import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/main.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/settings/settings_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/onboarding/onboarding_provider.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';

void main() {
  group('Add Expense Navigation Integration Tests', () {
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

    testWidgets('Long press category button should navigate to Add Expense Sheet', (
      WidgetTester tester,
    ) async {
      // 1. Setup test data
      final testDomain = DomainEntity(id: 1, name: 'Personal');
      await domainProvider.set([testDomain], syncStorage: false);
      final testCategory = CategoryEntity(id: 1, name: 'Food', enabled: true, domainId: 1);
      await categoryProvider.set([testCategory], syncStorage: false);

      // 2. Build the app
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

      // 3. Verify on Home page and category button exists
      expect(find.text('Food'), findsOneWidget);

      // 4. Long press the category button
      await tester.tap(find.text('Food')); // Just to clear focus if needed
      await tester.longPress(find.text('Food'));
      await tester.pumpAndSettle();

      // 5. Verify Add Expense bottom sheet is visible
      expect(find.text('Add Expense'), findsOneWidget, reason: 'Bottom sheet should be visible');
      expect(
        find.text('Category: Food'),
        findsOneWidget,
        reason: 'Should show correct category in sheet',
      );
    });

    testWidgets('Tapping back on Add Expense Sheet returns to Home', (WidgetTester tester) async {
      // 1. Setup
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

      // 2. Open sheet
      await tester.longPress(find.text('Food'));
      await tester.pumpAndSettle();
      expect(find.text('Add Expense'), findsOneWidget);

      // 3. Tap "Back" button in the sheet
      final backButton = find.text('Back');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // 4. Verify back on Home (sheet dismissed)
      expect(find.text('Add Expense'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Successfully adding an expense via sheet returns to Home', (
      WidgetTester tester,
    ) async {
      // 1. Setup
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

      // 2. Open sheet
      await tester.longPress(find.text('Food'));
      await tester.pumpAndSettle();

      // 3. Fill data
      await tester.enterText(find.byType(TextFormField).first, '100.00');

      // 4. Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // 5. Verify back on Home and expense added
      expect(find.text('Add Expense'), findsNothing);
      expect(expenseProvider.expenses.length, 1);
      expect(find.text('Expense added'), findsOneWidget);
    });
  });
}
