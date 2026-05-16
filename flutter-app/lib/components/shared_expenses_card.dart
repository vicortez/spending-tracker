import 'package:flutter/material.dart';
import 'package:spending_tracker/components/ui/card.dart';
import 'package:spending_tracker/router/navigation_extensions.dart';
import 'package:spending_tracker/router/route_utils.dart';

class SharedExpensesCard extends StatelessWidget {
  const SharedExpensesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushWithHistory(AppRouteConstants.sharedExpensesPath);
      },
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Shared expenses', style: Theme.of(context).textTheme.titleMedium),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
