import 'package:flutter/material.dart';
import 'package:spending_tracker/utils/color_utils.dart';

enum ButtonType { normal, secondary, danger, theme }

const baseAnimationDurationMs = 80;

class CoolButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool outline;
  final Color? bgColor;
  final Color? textColor;
  final Color? baseColor;
  final bool autoBaseColor;

  const CoolButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.normal,
    this.outline = false,
    this.bgColor,
    this.textColor,
    this.baseColor,
    this.autoBaseColor = true,
  });

  @override
  State<CoolButton> createState() => _CoolButtonState();
}

class _CoolButtonState extends State<CoolButton> {
  bool _isPressed = false;
  DateTime? _pressStartTime;

  void _handleTapDown() {
    setState(() {
      _isPressed = true;
      _pressStartTime = DateTime.now();
    });
  }

  void _handleTapUp() async {
    final pressedDuration = DateTime.now().difference(_pressStartTime ?? DateTime.now());
    final minAnimationDuration = Duration(milliseconds: baseAnimationDurationMs);

    // Ensure animation is visible for at least minAnimationDuration
    if (pressedDuration < minAnimationDuration) {
      await Future.delayed(minAnimationDuration - pressedDuration);
    }

    if (mounted) {
      setState(() => _isPressed = false);
    }

    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
      _pressStartTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    final style = _getStyle(context, isEnabled);

    final Color faceColor = widget.bgColor ?? style.faceColor;
    final Color baseColor =
        widget.baseColor ??
        (widget.autoBaseColor && widget.bgColor != null
            ? darken(widget.bgColor!, 20)
            : style.baseColor);
    final Color textColor = widget.textColor ?? style.textColor;

    const double borderRadius = 12.0;
    const double depth = 4.0;
    final double currentOutlineWidth = widget.outline ? 2.0 : 0.0;
    const double buttonHeight = 50.0;

    final bool isActuallyPressed = isEnabled && _isPressed;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _handleTapDown() : null,
      onTapUp: isEnabled ? (_) => _handleTapUp() : null,
      onTapCancel: isEnabled ? () => _handleTapCancel() : null,
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child: Stack(
          children: [
            // Base layer (Shadow/Depth + Outline container)
            AnimatedPositioned(
              duration: const Duration(milliseconds: baseAnimationDurationMs),
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
              duration: const Duration(milliseconds: baseAnimationDurationMs),
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

  _CoolButtonStyle _getStyle(BuildContext context, bool isEnabled) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!isEnabled) {
      final Color face = widget.type == ButtonType.danger
          ? darken(Colors.red, 40)
          : Colors.grey[800]!;
      final Color base = widget.type == ButtonType.danger
          ? darken(Colors.red, 60)
          : Colors.grey[900]!;
      return _CoolButtonStyle(faceColor: face, baseColor: base, textColor: Colors.grey[600]!);
    }

    switch (widget.type) {
      case ButtonType.normal:
        return _CoolButtonStyle(
          faceColor: colorScheme.primary,
          baseColor: darken(colorScheme.primary, 20),
          textColor: colorScheme.onPrimary,
        );
      case ButtonType.secondary:
        return _CoolButtonStyle(
          faceColor: colorScheme.secondary,
          baseColor: darken(colorScheme.secondary, 20),
          textColor: colorScheme.onSecondary,
        );
      case ButtonType.danger:
        return _CoolButtonStyle(
          faceColor: Colors.red,
          baseColor: darken(Colors.red, 20),
          textColor: Colors.white,
        );
      case ButtonType.theme:
        final isDark = colorScheme.brightness == Brightness.dark;
        return _CoolButtonStyle(
          faceColor: colorScheme.surface,
          baseColor: isDark ? lighten(colorScheme.surface, 20) : darken(colorScheme.surface, 20),
          textColor: colorScheme.onSurface,
        );
    }
  }
}

class _CoolButtonStyle {
  final Color faceColor;
  final Color baseColor;
  final Color textColor;

  const _CoolButtonStyle({
    required this.faceColor,
    required this.baseColor,
    required this.textColor,
  });
}
