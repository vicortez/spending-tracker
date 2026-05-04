import 'package:flutter/material.dart';
import 'package:spending_tracker/utils/color_utils.dart';

enum ButtonType { normal, danger }

class CoolButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool outline;
  final Color? bgColor;
  final Color? textColor;
  final Color? baseColor;

  const CoolButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.normal,
    this.outline = false,
    this.bgColor,
    this.textColor,
    this.baseColor,
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

    Color themeColor = widget.type == ButtonType.danger ? Colors.red : colorScheme.primary;
    Color effectiveFaceColor = widget.bgColor ?? themeColor;
    Color effectiveBaseColor = widget.baseColor ?? darken(effectiveFaceColor, 20);

    Color faceColor;
    Color baseColor;
    Color textColor;

    if (isEnabled) {
      faceColor = effectiveFaceColor;
      baseColor = effectiveBaseColor;
      textColor =
          widget.textColor ??
          (widget.type == ButtonType.danger ? Colors.white : colorScheme.onPrimary);
    } else {
      // Solid colors for disabled state
      faceColor = widget.type == ButtonType.danger ? darken(Colors.red, 40) : Colors.grey[800]!;
      baseColor = widget.type == ButtonType.danger ? darken(Colors.red, 60) : Colors.grey[900]!;
      textColor = Colors.grey[600]!;
    }

    const double borderRadius = 12.0;
    const double depth = 4.0;
    final double currentOutlineWidth = widget.outline ? 2.0 : 0.0;
    const double buttonHeight = 50.0;

    final bool isActuallyPressed = isEnabled && _isPressed;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: Stack(
          children: [
            // Base layer (Shadow/Depth + Outline container)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 70),
              top: isActuallyPressed ? depth : 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
            // Face layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 70),
              top: currentOutlineWidth + (isActuallyPressed ? depth : 0),
              left: currentOutlineWidth,
              right: currentOutlineWidth,
              bottom: currentOutlineWidth + (isActuallyPressed ? 0 : depth),
              child: Container(
                decoration: BoxDecoration(
                  color: faceColor,
                  borderRadius: BorderRadius.circular(borderRadius - currentOutlineWidth),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
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
