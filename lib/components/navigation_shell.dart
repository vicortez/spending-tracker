import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/components/app_bottom_navigation_bar.dart';
import 'package:spending_tracker/components/onboarding_handler.dart';
import 'package:spending_tracker/router/route_utils.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';

class MainNavigationShell extends StatefulWidget {
  final Widget child;

  const MainNavigationShell({super.key, required this.child});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  @override
  void initState() {
    super.initState();

    // Initialize navigation history with current location on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentLocation = GoRouterState.of(context).uri.toString();
        context.read<NavigationHistoryService>().push(currentLocation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyService = context.watch<NavigationHistoryService>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        // Get current location from router
        final currentLocation = GoRouterState.of(context).uri.toString();

        // Custom back button logic
        if (historyService.hasHistory) {
          // Pop from history and navigate to previous location
          final previousLocation = historyService.pop();
          if (previousLocation != null && previousLocation != currentLocation) {
            context.go(previousLocation);
          }
        } else if (currentLocation != AppRouteConstants.homePath) {
          // No history but not on home - go to home
          historyService.clear();
          historyService.push(AppRouteConstants.homePath);
          context.go(AppRouteConstants.homePath);
        } else {
          // On home with no history - exit app
          SystemNavigator.pop();
        }
      },
      child: OnboardingHandler(
        child: Scaffold(
          body: SafeArea(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Container(
                margin: const EdgeInsets.all(10.0),
                child: widget.child,
              ),
            ),
          ),
          bottomNavigationBar: const AppBottomNavigationBar(),
        ),
      ),
    );
  }
}
