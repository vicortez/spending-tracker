import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/router/route_utils.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  void _onItemTapped(int index, BuildContext context) {
    final path = AppRouteConstants.tabIndexToPath[index];
    if (path != null) {
      final currentLocation = GoRouterState.of(context).uri.toString();

      // Only navigate and track history if switching to a different tab
      if (currentLocation != path) {
        // Add to navigation history before navigating
        context.read<NavigationHistoryService>().push(path);
        context.go(path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final int selectedIndex = AppRouteConstants.getTabIndex(location);

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(index, context),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.label_outline), label: 'Categories'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'About'),
      ],
    );
  }
}
