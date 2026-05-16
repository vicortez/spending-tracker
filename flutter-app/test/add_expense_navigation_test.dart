import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/pages/add_expense_page.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/focused_month/focused_month_provider.dart';
import 'package:spending_tracker/repository/onboarding/onboarding_provider.dart';

void main() {
  group('Add Expense Navigation and Confirmation Dialog Tests', () {
    late CategoryProvider categoryProvider;
    late DomainProvider domainProvider;
    late ExpenseProvider expenseProvider;
    late ConfigProvider configProvider;
    late FocusedMonthProvider focusedMonthProvider;
    late OnboardingProvider onboardingProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      categoryProvider = CategoryProvider();
      domainProvider = DomainProvider();
      expenseProvider = ExpenseProvider();
      configProvider = ConfigProvider();
      focusedMonthProvider = FocusedMonthProvider();
      onboardingProvider = OnboardingProvider();

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

    testWidgets('Can navigate back with context.pop() from add expense page',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.push(
                    '/add-expense',
                    extra: {
                      'categoryId': 1,
                      'categoryName': 'Test',
                      'amount': '50.00',
                      'date': '2024-01-01',
                    },
                  ),
                  child: const Text('Go to Add Expense'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/add-expense',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return AddExpensePage(
                categoryId: extra['categoryId'] as int,
                categoryName: extra['categoryName'] as String,
                amount: extra['amount'] as String,
                date: extra['date'] as String,
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: categoryProvider),
            ChangeNotifierProvider.value(value: domainProvider),
            ChangeNotifierProvider.value(value: expenseProvider),
            ChangeNotifierProvider.value(value: configProvider),
            ChangeNotifierProvider.value(value: focusedMonthProvider),
            ChangeNotifierProvider.value(value: onboardingProvider),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to add expense page
      await tester.tap(find.text('Go to Add Expense'));
      await tester.pumpAndSettle();

      // Verify we're on the add expense page
      expect(find.text('Add expense'), findsOneWidget);

      // Tap back button
      await tester.tap(find.widgetWithText(CoolButton, 'Back'));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Discard changes?'), findsOneWidget);
      expect(find.text('You have unsaved changes. Are you sure you want to leave?'), findsOneWidget);
    });

    testWidgets('Clicking Discard navigates back successfully', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Column(
                  children: [
                    const Text('Home Page'),
                    ElevatedButton(
                      onPressed: () => context.push(
                        '/add-expense',
                        extra: {
                          'categoryId': 1,
                          'categoryName': 'Test',
                          'amount': '50.00',
                          'date': '2024-01-01',
                        },
                      ),
                      child: const Text('Go to Add Expense'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/add-expense',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return AddExpensePage(
                categoryId: extra['categoryId'] as int,
                categoryName: extra['categoryName'] as String,
                amount: extra['amount'] as String,
                date: extra['date'] as String,
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: categoryProvider),
            ChangeNotifierProvider.value(value: domainProvider),
            ChangeNotifierProvider.value(value: expenseProvider),
            ChangeNotifierProvider.value(value: configProvider),
            ChangeNotifierProvider.value(value: focusedMonthProvider),
            ChangeNotifierProvider.value(value: onboardingProvider),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to add expense page
      await tester.tap(find.text('Go to Add Expense'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.widgetWithText(CoolButton, 'Back'));
      await tester.pumpAndSettle();

      // Click Discard
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // Should be back on home page
      expect(find.text('Home Page'), findsOneWidget);
      expect(find.text('Add expense'), findsNothing);
    });

    testWidgets('Clicking Cancel keeps user on form', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.push(
                    '/add-expense',
                    extra: {
                      'categoryId': 1,
                      'categoryName': 'Test',
                      'amount': '50.00',
                      'date': '2024-01-01',
                    },
                  ),
                  child: const Text('Go to Add Expense'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/add-expense',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return AddExpensePage(
                categoryId: extra['categoryId'] as int,
                categoryName: extra['categoryName'] as String,
                amount: extra['amount'] as String,
                date: extra['date'] as String,
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: categoryProvider),
            ChangeNotifierProvider.value(value: domainProvider),
            ChangeNotifierProvider.value(value: expenseProvider),
            ChangeNotifierProvider.value(value: configProvider),
            ChangeNotifierProvider.value(value: focusedMonthProvider),
            ChangeNotifierProvider.value(value: onboardingProvider),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to add expense page
      await tester.tap(find.text('Go to Add Expense'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.widgetWithText(CoolButton, 'Back'));
      await tester.pumpAndSettle();

      // Click Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should still be on add expense page
      expect(find.text('Add expense'), findsOneWidget);
    });
  });
}
