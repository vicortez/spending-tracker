import 'package:flutter/material.dart';
import 'package:spending_tracker/components/app_bottom_navigation_bar.dart';
import 'package:spending_tracker/components/onboarding_handler.dart';

class MainNavigationShell extends StatelessWidget {
  final Widget child;

  const MainNavigationShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return OnboardingHandler(
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Container(margin: const EdgeInsets.all(10.0), child: child),
          ),
        ),
        bottomNavigationBar: const AppBottomNavigationBar(),
      ),
    );
  }
}
