import 'package:flutter/material.dart';

/// Shows a reusable bottom sheet that slides up from the bottom
void showMyBottomSheet({
  required BuildContext context,
  required String title,
  String? subtitle,
  List<Widget>? actions,
  Widget? content,
  double maxHeightFactor = 0.8,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MyBottomSheet(
      title: title,
      subtitle: subtitle,
      actions: actions,
      content: content,
      maxHeightFactor: maxHeightFactor,
    ),
  );
}

/// A reusable bottom sheet component with consistent styling
class MyBottomSheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? content;
  final double maxHeightFactor;

  const MyBottomSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.content,
    this.maxHeightFactor = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * maxHeightFactor),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      iconSize: 24,
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Content
          if (content != null)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: content,
              ),
            ),

          // Actions
          if (actions != null && actions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(children: actions!),
            ),

          // Bottom padding if no actions
          if (actions == null || actions!.isEmpty) const SizedBox(height: 24),
        ],
      ),
    );
  }
}
