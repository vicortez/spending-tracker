import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';

class ChooseEntityToManagePage extends StatelessWidget {
  const ChooseEntityToManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    double buttonHeight = 60;
    return Scaffold(
      appBar: AppBar(title: const Text('Select entity to manage')),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: buttonHeight,
                  child: CoolButton(
                    text: 'Manage Categories',
                    type: ButtonType.normal,
                    onPressed: () {
                      // Use context.push() - GoRouter handles back button automatically
                      context.push('/categories/manage-categories');
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: buttonHeight,
                  child: CoolButton(
                    text: 'Manage Domains',
                    type: ButtonType.normal,
                    onPressed: () {
                      // Use context.push() - GoRouter handles back button automatically
                      context.push('/categories/manage-domains');
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
