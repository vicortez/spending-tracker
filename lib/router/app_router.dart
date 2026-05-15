import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spending_tracker/components/navigation_shell.dart';
import 'package:spending_tracker/pages/add_expense_page.dart';
import 'package:spending_tracker/pages/choose_entity_to_manage_page.dart';
import 'package:spending_tracker/pages/edit_expense_page.dart';
import 'package:spending_tracker/pages/home_page.dart';
import 'package:spending_tracker/pages/info_page.dart';
import 'package:spending_tracker/pages/list_expenses_page.dart';
import 'package:spending_tracker/pages/manage_categories_page.dart';
import 'package:spending_tracker/pages/manage_domains_page.dart';
import 'package:spending_tracker/pages/reports_page.dart';
import 'package:spending_tracker/pages/settings_page.dart';
import 'package:spending_tracker/pages/top_categories_page.dart';
import 'package:spending_tracker/router/route_utils.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  initialLocation: AppRouteConstants.homePath,
  navigatorKey: rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return MainNavigationShell(child: child);
      },
      routes: [
        GoRoute(path: AppRouteConstants.homePath, builder: (context, state) => const HomePage()),
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
        GoRoute(
          path: AppRouteConstants.categoriesPath,
          builder: (context, state) => const ChooseEntityToManagePage(),
          routes: [
            GoRoute(
              path: 'manage-categories',
              builder: (context, state) => const ManageCategoriesPage(),
            ),
            GoRoute(path: 'manage-domains', builder: (context, state) => const ManageDomainsPage()),
          ],
        ),
        GoRoute(
          path: AppRouteConstants.reportsPath,
          builder: (context, state) => const ReportsPage(),
          routes: [
            GoRoute(
              path: AppRouteConstants.editExpensePath,
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return EditExpensePage(expenseId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRouteConstants.topCategoriesPath,
          builder: (context, state) => const TopCategoriesPage(),
        ),
        GoRoute(
          path: AppRouteConstants.allExpensesPath,
          builder: (context, state) => const ListExpensesPage(),
        ),
        GoRoute(
          path: AppRouteConstants.settingsPath,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(path: AppRouteConstants.aboutPath, builder: (context, state) => const InfoPage()),
      ],
    ),
  ],
);
