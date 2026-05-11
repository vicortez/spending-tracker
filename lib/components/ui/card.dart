import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;

  const CustomCard({super.key, required this.child, this.backgroundColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    // final bool isDarkMode = Theme.of(context).colorScheme.brightness == Brightness.dark;

    final Color defaultBackgroundColor = Theme.of(context).colorScheme.surface;

    final Color defaultBorderColor = Colors.cyan[900]!;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? defaultBorderColor, width: 1),
      ),
      child: child,
    );
  }
}
