import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/repository/onboarding/onboarding_provider.dart';
import 'package:spending_tracker/router/route_utils.dart';
import 'package:spending_tracker/translations/translations.dart';

class OnboardingHandler extends StatefulWidget {
  final Widget child;

  const OnboardingHandler({super.key, required this.child});

  @override
  State<OnboardingHandler> createState() => _OnboardingHandlerState();
}

class _OnboardingHandlerState extends State<OnboardingHandler> {
  OnboardingStep? _lastStep;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkStep();
  }

  void _checkStep() {
    final state = context.watch<OnboardingProvider>();
    if (_lastStep != state.currentStep) {
      final nextStep = state.currentStep;
      _lastStep = nextStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showDialogForStep(context, nextStep);
        }
      });
    }
  }

  void _showDialogForStep(BuildContext context, OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        _showWelcomeDialog(context);
        break;
      case OnboardingStep.categories:
        _showCategoriesWelcomeDialog(context);
        break;
      default:
        break;
    }
  }

  Future<void> _showWelcomeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Welcome!'),
          content: const Text(welcome1),
          actions: <Widget>[
            const Text('1/2'),
            TextButton(
              child: const Text('Next'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<OnboardingProvider>().moveToNextStep();
                context.go(AppRouteConstants.categoriesPath);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCategoriesWelcomeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Manage Categories and Domains'),
          content: const Text(welcomeCategories),
          actions: <Widget>[
            const Text('2/2'),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<OnboardingProvider>().moveToNextStep();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
