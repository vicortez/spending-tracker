import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/focused_month/focused_month_provider.dart';
import 'package:spending_tracker/repository/onboarding/onboarding_provider.dart';
import 'package:spending_tracker/router/app_router.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';

void main() {
  group('Add Expense Flow Integration Tests', () {
    late CategoryProvider categoryProvider;
    late DomainProvider domainProvider;
    late ExpenseProvider expenseProvider;
    late ConfigProvider configProvider;
    late FocusedMonthProvider focusedMonthProvider;
    late OnboardingProvider onboardingProvider;
    late NavigationHistoryService navigationHistoryService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      categoryProvider = CategoryProvider();
      domainProvider = DomainProvider();
      expenseProvider = ExpenseProvider();
      configProvider = ConfigProvider();
      focusedMonthProvider = FocusedMonthProvider();
      onboardingProvider = OnboardingProvider();
      navigationHistoryService = NavigationHistoryService();

      await categoryProvider.loadCategoriesFromLocalStorage(prefs);
      domainProvider.loadFromLocalStorage(prefs);
      await expenseProvider.loadFromLocalStorage(prefs);
      configProvider.loadFromLocalStorage(prefs);
      focusedMonthProvider.loadFromLocalStorage(prefs);
      onboardingProvider.init(prefs);

      // Add test data
      final testDomain = DomainEntity(id: 1, name: 'Test Domain');
      domainProvider.setDomains([testDomain], syncStorage: false);

      final testCategory = CategoryEntity(
        id: 1,
        name: 'Test Category',
        enabled: true,
        domainId: testDomain.id,
      );
      categoryProvider.setCategories([testCategory], syncStorage: false);
    });

    testWidgets('Complete flow: hold button -> edit before save -> confirmation dialog',
        (WidgetTester tester) async {
      // Build the app with providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: categoryProvider),
            ChangeNotifierProvider.value(value: domainProvider),
            ChangeNotifierProvider.value(value: expenseProvider),
            ChangeNotifierProvider.value(value: configProvider),
            ChangeNotifierProvider.value(value: focusedMonthProvider),
            ChangeNotifierProvider.value(value: onboardingProvider),
            ChangeNotifierProvider.value(value: navigationHistoryService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Step 1: Enter an amount in the text field
      final amountTextField = find.byType(TextField);
      expect(amountTextField, findsOneWidget);

      await tester.enterText(amountTextField, '42.50');
      await tester.pumpAndSettle();

      // Step 2: Find and long-press the category button
      final categoryButton = find.widgetWithText(CoolButton, 'Test Category');
      expect(categoryButton, findsOneWidget);

      // Simulate long press by triggering onHold
      await tester.longPress(categoryButton);
      await tester.pumpAndSettle();

      // Step 3: Verify AddExpenseBottomSheet appears with "Edit before saving" button
      expect(find.text('Test Category'), findsAtLeastNWidgets(1));
      expect(find.text('Domain: Test Domain'), findsOneWidget);
      expect(find.text('Edit before saving'), findsOneWidget);

      // Step 4: Click "Edit before saving" button
      final editButton = find.widgetWithText(CoolButton, 'Edit before saving');
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Step 5: Verify navigation to expense form
      expect(find.text('Add expense'), findsOneWidget);

      // Verify pre-filled values
      final amountField = find.widgetWithText(TextFormField, '42.50');
      expect(amountField, findsOneWidget);

      // Step 6: Try to go back using the Back button
      final backButton = find.widgetWithText(CoolButton, 'Back');
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Step 7: Verify confirmation dialog appears
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('You have unsaved changes. Are you sure you want to leave?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
    });

    testWidgets('Clicking Cancel keeps user on the form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: categoryProvider),
            ChangeNotifierProvider.value(value: domainProvider),
            ChangeNotifierProvider.value(value: expenseProvider),
            ChangeNotifierProvider.value(value: configProvider),
            ChangeNotifierProvider.value(value: focusedMonthProvider),
            ChangeNotifierProvider.value(value: onboardingProvider),
            ChangeNotifierProvider.value(value: navigationHistoryService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount and hold category button
      final textField = find.byType(TextField);
      await tester.ensureVisible(textField);
      await tester.enterText(textField, '100.00');
      await tester.pumpAndSettle();

      final categoryButton = find.widgetWithText(CoolButton, 'Test Category');
      await tester.ensureVisible(categoryButton);
      await tester.pumpAndSettle();

      // Trigger long press to show bottom sheet
      await tester.longPress(categoryButton, warnIfMissed: false);
      // Wait for the hold timer (400ms) and animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CoolButton, 'Edit before saving'));
      await tester.pumpAndSettle();

      // Try to go back
      await tester.tap(find.widgetWithText(CoolButton, 'Back'));
      await tester.pumpAndSettle();

      // Click Cancel on confirmation dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify still on the form
      expect(find.text('Add expense'), findsOneWidget);
      expect(find.widgetWithText(CoolButton, 'Save'), findsOneWidget);
    });

    testWidgets('Clicking Discard returns to home page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: categoryProvider),
            ChangeNotifierProvider.value(value: domainProvider),
            ChangeNotifierProvider.value(value: expenseProvider),
            ChangeNotifierProvider.value(value: configProvider),
            ChangeNotifierProvider.value(value: focusedMonthProvider),
            ChangeNotifierProvider.value(value: onboardingProvider),
            ChangeNotifierProvider.value(value: navigationHistoryService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount and hold category button
      final textField = find.byType(TextField);
      await tester.ensureVisible(textField);
      await tester.enterText(textField, '100.00');
      await tester.pumpAndSettle();

      final categoryButton = find.widgetWithText(CoolButton, 'Test Category');
      await tester.ensureVisible(categoryButton);
      await tester.pumpAndSettle();

      // Trigger long press to show bottom sheet
      await tester.longPress(categoryButton, warnIfMissed: false);
      // Wait for the hold timer (400ms) and animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CoolButton, 'Edit before saving'));
      await tester.pumpAndSettle();

      // Try to go back
      await tester.tap(find.widgetWithText(CoolButton, 'Back'));
      await tester.pumpAndSettle();

      // Click Discard on confirmation dialog
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // Verify returned to home page
      expect(find.text('Add expense'), findsNothing);
      expect(find.byType(TextField), findsOneWidget); // Home page has text field
    });

    testWidgets('Saving expense does not show confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: categoryProvider),
            ChangeNotifierProvider.value(value: domainProvider),
            ChangeNotifierProvider.value(value: expenseProvider),
            ChangeNotifierProvider.value(value: configProvider),
            ChangeNotifierProvider.value(value: focusedMonthProvider),
            ChangeNotifierProvider.value(value: onboardingProvider),
            ChangeNotifierProvider.value(value: navigationHistoryService),
          ],
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter amount and hold category button
      await tester.enterText(find.byType(TextField), '75.25');
      await tester.pumpAndSettle();

      await tester.longPress(find.widgetWithText(CoolButton, 'Test Category'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(CoolButton, 'Edit before saving'));
      await tester.pumpAndSettle();

      // Save the expense
      await tester.tap(find.widgetWithText(CoolButton, 'Save'));
      await tester.pumpAndSettle();

      // Verify no confirmation dialog appeared and returned to home page
      expect(find.text('Discard changes?'), findsNothing);
      expect(find.text('Add expense'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);

      // Verify expense was added
      expect(expenseProvider.expenses.length, 1);
      expect(expenseProvider.expenses.first.amount, 75.25);
      expect(expenseProvider.expenses.first.categoryId, 1);
    });
  });
}
