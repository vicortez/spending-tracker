import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/main.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/focused_month/focused_month_provider.dart';
import 'package:spending_tracker/repository/onboarding/onboarding_provider.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';

void main() {
  group('Android Back Button Navigation Tests', () {
    testWidgets('Back button should navigate from Categories to Home instead of closing app',
        (WidgetTester tester) async {
      // 1. Initialize Mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'isFirstRun': false, // Skip onboarding
      });

      final categoryProvider = CategoryProvider();
      final expenseProvider = ExpenseProvider();
      final configProvider = ConfigProvider();
      final focusedMonthProvider = FocusedMonthProvider();
      final domainProvider = DomainProvider();
      final onboardingProvider = OnboardingProvider();
      final navigationHistoryService = NavigationHistoryService();

      // 2. Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
            ChangeNotifierProvider<ConfigProvider>.value(value: configProvider),
            ChangeNotifierProvider<FocusedMonthProvider>.value(value: focusedMonthProvider),
            ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
            ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
            ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 3. Verify we start on Home page (has TextField for amount input)
      expect(find.byType(TextField), findsOneWidget, reason: 'Should start on Home page');

      // Verify navigation history initialized with home
      expect(navigationHistoryService.history, ['/'], reason: 'History should start with home');

      // 4. Tap the Categories tab in bottom navigation
      final categoriesTab = find.byIcon(Icons.label_outline);
      expect(categoriesTab, findsOneWidget);
      await tester.tap(categoriesTab);
      await tester.pumpAndSettle();

      // 5. Verify we're on Categories page
      expect(find.text('Categories'), findsOneWidget, reason: 'Should be on Categories page');

      // Verify navigation history tracked the navigation
      expect(
        navigationHistoryService.history,
        ['/', '/categories'],
        reason: 'History should track Home -> Categories navigation',
      );

      // 6. Simulate Android back button press
      // This triggers the PopScope's onPopInvokedWithResult callback
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // 7. EXPECTED BEHAVIOR: Should navigate back to Home page
      // The TextField should be visible again (it's only on Home page)
      expect(
        find.byType(TextField),
        findsOneWidget,
        reason: 'Back button should navigate to Home page, not close app',
      );

      // Verify we're on home by checking the bottom nav selected index
      final bottomNav = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, 0, reason: 'Should be on Home tab (index 0)');

      // Verify navigation history was popped
      expect(
        navigationHistoryService.history,
        ['/'],
        reason: 'History should be back to just home after pop',
      );
    });

    testWidgets('Back button on Home page should allow app exit', (WidgetTester tester) async {
      // Initialize
      SharedPreferences.setMockInitialValues({'isFirstRun': false});

      final categoryProvider = CategoryProvider();
      final expenseProvider = ExpenseProvider();
      final configProvider = ConfigProvider();
      final focusedMonthProvider = FocusedMonthProvider();
      final domainProvider = DomainProvider();
      final onboardingProvider = OnboardingProvider();
      final navigationHistoryService = NavigationHistoryService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
            ChangeNotifierProvider<ConfigProvider>.value(value: configProvider),
            ChangeNotifierProvider<FocusedMonthProvider>.value(value: focusedMonthProvider),
            ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
            ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
            ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify on Home with only home in history
      expect(find.byType(TextField), findsOneWidget);
      expect(navigationHistoryService.history, ['/']);

      // Press back button on Home page
      // Should trigger SystemNavigator.pop() which can't be tested in widget tests
      // But we can verify the navigation history state is correct for exit
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // The PopScope should have handled it (returned true or allowed system to handle)
      // We can't test SystemNavigator.pop() in widget tests, but we can verify the state
      expect(navigationHistoryService.hasHistory, false, reason: 'No history to navigate back to');
    });

    testWidgets(
        'Back button should navigate through GoRouter history '
        '(Categories -> Manage Categories -> Back -> Categories -> Back -> Home)',
        (WidgetTester tester) async {
      // Initialize
      SharedPreferences.setMockInitialValues({'isFirstRun': false});

      final categoryProvider = CategoryProvider();
      final expenseProvider = ExpenseProvider();
      final configProvider = ConfigProvider();
      final focusedMonthProvider = FocusedMonthProvider();
      final domainProvider = DomainProvider();
      final onboardingProvider = OnboardingProvider();
      final navigationHistoryService = NavigationHistoryService();

      // Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
            ChangeNotifierProvider<ConfigProvider>.value(value: configProvider),
            ChangeNotifierProvider<FocusedMonthProvider>.value(value: focusedMonthProvider),
            ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
            ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
            ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Start on Home
      expect(find.byType(TextField), findsOneWidget);
      expect(navigationHistoryService.history, ['/']);

      // Navigate to Categories tab
      final categoriesTab = find.byIcon(Icons.label_outline);
      await tester.tap(categoriesTab);
      await tester.pumpAndSettle();

      // Verify on Categories page
      expect(find.text('Select entity to manage'), findsOneWidget);
      expect(navigationHistoryService.history, ['/', '/categories']);

      // Tap "Manage Categories" button - uses context.push() (not tracked in global history)
      final manageCategoriesButton = find.text('Manage Categories');
      expect(manageCategoriesButton, findsOneWidget);
      await tester.tap(manageCategoriesButton);
      await tester.pumpAndSettle();

      // Verify on Manage Categories page
      expect(find.text('Manage categories'), findsOneWidget);
      // Global history should NOT change for pushed routes (GoRouter handles them)
      expect(
        navigationHistoryService.history,
        ['/', '/categories'],
        reason: 'Pushed routes are not tracked in global history',
      );

      // Press back button - GoRouter automatically pops to Categories page
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Should be back on Categories page (Choose Entity page)
      expect(
        find.text('Select entity to manage'),
        findsOneWidget,
        reason: 'Should navigate back to Choose Entity page via GoRouter pop',
      );

      // Global history unchanged (pushed route wasn't tracked)
      expect(
        navigationHistoryService.history,
        ['/', '/categories'],
        reason: 'History unchanged - GoRouter handled the push/pop',
      );

      // Press back again - should go to Home
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Should be back on Home page
      expect(find.byType(TextField), findsOneWidget, reason: 'Should navigate back to Home');
      expect(navigationHistoryService.history, ['/'], reason: 'History should pop to home');
    });
  });
}
