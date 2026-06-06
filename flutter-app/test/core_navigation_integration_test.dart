import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/main.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/category/category_provider.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/repository/domain/domain_provider.dart';
import 'package:spending_tracker/repository/expense/expense_provider.dart';
import 'package:spending_tracker/repository/onboarding/onboarding_provider.dart';
import 'package:spending_tracker/repository/services/auth_provider.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';

void main() {
  testWidgets('Core navigation and expense workflow smoke test using MyApp', (
    WidgetTester tester,
  ) async {
    // 1. Initialize Mock SharedPreferences
    SharedPreferences.setMockInitialValues({
      'isFirstRun': false, // Avoid welcome dialog for simplicity
    });

    final categoryProvider = CategoryProvider();
    final expenseProvider = ExpenseProvider();
    final configProvider = ConfigProvider();
    final domainProvider = DomainProvider();
    final onboardingProvider = OnboardingProvider();
    final authProvider = AuthProvider();
    final navigationHistoryService = NavigationHistoryService();

    // 2. Setup mock categories
    categoryProvider.set([
      CategoryEntity(id: 1, name: 'Food', enabled: true),
      CategoryEntity(id: 2, name: 'Transport', enabled: true),
    ], syncStorage: false);

    // 3. Build the app using MyApp
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
          ChangeNotifierProvider<CategoryProvider>.value(value: categoryProvider),
          ChangeNotifierProvider<ConfigProvider>.value(value: configProvider),
          ChangeNotifierProvider<DomainProvider>.value(value: domainProvider),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<NavigationHistoryService>.value(value: navigationHistoryService),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 4. Add an expense on HomePage
    final amountField = find.byType(TextField);
    expect(amountField, findsOneWidget);

    await tester.enterText(amountField, '50.0');
    await tester.pump();

    final foodButton = find.text('Food');
    expect(foodButton, findsOneWidget);
    await tester.tap(foodButton);
    await tester.pumpAndSettle();

    expect(expenseProvider.expenses.length, 1);
    expect(expenseProvider.expenses.first.amount, 50.0);

    // 5. Navigate to Reports page
    final reportTab = find.byIcon(Icons.receipt_long_outlined);
    expect(reportTab, findsOneWidget);
    await tester.tap(reportTab);
    await tester.pumpAndSettle();

    // 6. Verify expense in SpendingReportPage
    expect(find.text('Food'), findsWidgets);
    expect(find.text('50'), findsAtLeastNWidgets(1));

    // 7. Edit the expense
    final editIcon = find.byIcon(Icons.edit_outlined);
    expect(editIcon, findsOneWidget);
    await tester.tap(editIcon);
    await tester.pumpAndSettle();

    final amountEditField = find.widgetWithText(TextFormField, 'Amount');
    expect(amountEditField, findsOneWidget);
    await tester.enterText(amountEditField, '75.0');
    await tester.pump();

    final saveButton = find.text('Save');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // 8. Verify back on Reports page with updated value
    expect(find.text('75'), findsAtLeastNWidgets(1));
    expect(expenseProvider.expenses.first.amount, 75.0);
  });
}
