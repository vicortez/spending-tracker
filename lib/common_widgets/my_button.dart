import 'package:flutter/material.dart';

enum ButtonType { normal, danger }

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;

  const MyButton({Key? key, required this.text, this.onPressed, this.type = ButtonType.normal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color fontColor;
    switch (type) {
      case ButtonType.normal:
        backgroundColor = Theme.of(context).colorScheme.background;
        fontColor = Theme.of(context).colorScheme.primary;
        break;
      case ButtonType.danger:
        backgroundColor = Colors.red.withOpacity(0.7);
        fontColor = getTextColorForBackground(backgroundColor);
        break;
      default:
        backgroundColor = Theme.of(context).colorScheme.background;
        fontColor = Theme.of(context).colorScheme.primary;
        break;
    }
    return ElevatedButton(
      onPressed: onPressed != null ? () => onPressed!() : null,
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          foregroundColor: MaterialStateProperty.all(fontColor)),
      child: Text(
        text,
      ),
    );
  }

  Color getTextColorForBackground(Color backgroundColor) {
    if (ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark) {
      return Colors.white;
    }

    return Colors.black;
  }
}
