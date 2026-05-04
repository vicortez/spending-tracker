import 'package:flutter/material.dart';
import 'package:spending_tracker/utils/color_utils.dart';

enum ButtonType { normal, danger }

class CoolButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isOutline;
  final Color? bgColor;
  final Color? textColor;

  const CoolButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.normal,
    this.isOutline = false,
    this.bgColor,
    this.textColor,
  });

  @override
  State<CoolButton> createState() => _CoolButtonState();
}

class _CoolButtonState extends State<CoolButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final colorScheme = Theme.of(context).colorScheme;

    Color faceColor;
    Color baseColor;
    Color textColor;

    // Determine colors based on type and custom overrides
    switch (widget.type) {
      case ButtonType.normal:
        faceColor =
            widget.bgColor ??
            (isEnabled ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.12));
        textColor =
            widget.textColor ??
            (isEnabled ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.38));
        break;
      case ButtonType.danger:
        faceColor = widget.bgColor ?? (isEnabled ? Colors.red : Colors.red.withOpacity(0.3));
        textColor = widget.textColor ?? Colors.white;
        break;
    }

    baseColor = darken(faceColor, 20);

    // Handle outline variant
    if (widget.isOutline) {
      textColor = faceColor;
      faceColor = Colors.transparent;
      baseColor = isEnabled ? textColor.withOpacity(0.1) : Colors.transparent;
    }

    const double borderRadius = 12.0;
    const double depth = 4.0;
    const double buttonHeight = 50.0;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: IntrinsicHeight(
        child: Stack(
          children: [
            // Base layer (Shadow/Depth)
            if (!(_isPressed && isEnabled))
              Container(
                margin: const EdgeInsets.only(top: depth),
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: const SizedBox(width: double.infinity, height: buttonHeight - depth),
              ),
            // Face layer
            AnimatedContainer(
              duration: const Duration(milliseconds: 70),
              margin: EdgeInsets.only(
                bottom: (isEnabled && _isPressed) ? 0 : depth,
                top: (isEnabled && _isPressed) ? depth : 0,
              ),
              decoration: BoxDecoration(
                color: faceColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: widget.isOutline ? Border.all(color: textColor, width: 2) : null,
              ),
              child: Container(
                width: double.infinity,
                height: buttonHeight - depth,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.text, // Removed .toUpperCase()
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
