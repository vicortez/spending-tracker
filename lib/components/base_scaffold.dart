import 'package:flutter/material.dart';

/// we use this class instead of the scaffolding class
/// to wrap everything with stuff we want to avoid repetition.
/// Especially a SafeArea.
class BaseScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const BaseScaffold({super.key, required this.body, this.appBar, this.bottomNavigationBar, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    var bgColor = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: appBar,
      // If no color is passed, it uses the default Scaffold background color
      backgroundColor: bgColor,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(child: body),
    );
  }
}
