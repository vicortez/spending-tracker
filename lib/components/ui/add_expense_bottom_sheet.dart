import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/components/ui/my_bottom_sheet.dart';

/// Shows a bottom sheet with options for adding an expense
void showAddExpenseBottomSheet({
  required BuildContext context,
  required int categoryId,
  required String categoryName,
  required String domainName,
  required String expenseAmount,
}) {
  showMyBottomSheet(
    context: context,
    title: categoryName,
    subtitle: domainName,
    actions: [
      CoolButton(
        text: 'Edit before saving',
        onPressed: () {
          // Close the bottom sheet
          Navigator.of(context).pop();

          // Navigate to expense form with pre-filled values
          // Use push instead of go to maintain navigation stack
          final now = DateTime.now();
          final todayString =
              '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

          context.push(
            '/add-expense',
            extra: {
              'categoryId': categoryId,
              'categoryName': categoryName,
              'amount': expenseAmount,
              'date': todayString,
            },
          );
        },
        type: ButtonType.theme,
        outline: true,
        baseColor: Colors.grey[900],
        textColor: Colors.teal,
      ),
    ],
  );
}
