import 'package:flutter/material.dart';
import 'package:spending_tracker/utils/color_utils.dart';

enum ButtonType { normal, danger }

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;

  const MyButton({super.key, required this.text, this.onPressed, this.type = ButtonType.normal});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color fontColor;
    switch (type) {
      case ButtonType.normal:
        backgroundColor = lighten(Theme.of(context).colorScheme.surface, 8);
        fontColor = Theme.of(context).colorScheme.primary;
        break;
      case ButtonType.danger:
        backgroundColor = Colors.red.withOpacity(0.7);
        fontColor = getTextColorForBackground(backgroundColor);
        break;
      default:
        backgroundColor = Theme.of(context).colorScheme.surface;
        fontColor = Theme.of(context).colorScheme.primary;
        break;
    }
    return ElevatedButton(
      onPressed: onPressed != null ? () => onPressed!() : null,
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        backgroundColor: WidgetStateProperty.all(backgroundColor),
        foregroundColor: WidgetStateProperty.all(fontColor),
      ),
      child: Text(text),
    );
  }

  Color getTextColorForBackground(Color backgroundColor) {
    if (ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark) {
      return Colors.white;
    }

    return Colors.black;
  }
}
