import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spending_tracker/utils/color_utils.dart';

enum ButtonType { normal, secondary, danger, theme }

class CoolButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onHold;
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
    this.onHold,
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
  Timer? _holdTimer;
  bool _isHolding = false;
  double _scale = 1.0;

  static const int baseAnimationDurationMs = 40;
  static const double borderRadius = 10.0;
  static const double depth = 4.0;
  static const double buttonHeight = 50.0;
  static const int holdTimerMS = 400;

  void _handleTapDown() {
    setState(() {
      _isPressed = true;
      _pressStartTime = DateTime.now();
    });
  }

  void _handleTapUp() async {
    // Call onPressed immediately for instant responsiveness
    widget.onPressed?.call();

    final pressedDuration = DateTime.now().difference(_pressStartTime ?? DateTime.now());
    final minAnimationDuration = Duration(milliseconds: baseAnimationDurationMs);

    // Ensure animation is visible for at least minAnimationDuration
    if (pressedDuration < minAnimationDuration) {
      await Future.delayed(minAnimationDuration - pressedDuration);
    }

    if (mounted) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
      _pressStartTime = null;
    });
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    final bool isEnabled = widget.onPressed != null;
    if (!isEnabled || widget.onHold == null) return;

    setState(() {
      _isPressed = true;
      _pressStartTime = DateTime.now();
      _isHolding = false;
    });

    // Start timer for hold threshold
    _holdTimer = Timer(const Duration(milliseconds: holdTimerMS), () {
      if (mounted) {
        _triggerHoldAction();
      }
    });
  }

  void _triggerHoldAction() async {
    setState(() => _isHolding = true);

    // Quick scale-pulse animation
    // Scale up
    setState(() => _scale = 1.15);
    await Future.delayed(const Duration(milliseconds: 100));

    // Scale down
    if (mounted) {
      setState(() => _scale = 1.0);
    }
    await Future.delayed(const Duration(milliseconds: 100));

    // Trigger callback
    widget.onHold?.call();

    if (mounted) {
      setState(() => _isHolding = false);
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _holdTimer?.cancel();
    _holdTimer = null;

    if (!_isHolding && mounted) {
      setState(() => _isPressed = false);
    }
  }

  void _handleLongPressCancel() {
    _holdTimer?.cancel();
    _holdTimer = null;

    if (mounted) {
      setState(() {
        _isPressed = false;
        _isHolding = false;
        _scale = 1.0;
      });
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
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

    final double currentOutlineWidth = widget.outline ? 2.0 : 0.0;

    final bool isActuallyPressed = isEnabled && _isPressed;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _handleTapDown() : null,
      onTapUp: isEnabled ? (_) => _handleTapUp() : null,
      onTapCancel: isEnabled ? () => _handleTapCancel() : null,
      onLongPressStart: isEnabled && widget.onHold != null ? _handleLongPressStart : null,
      onLongPressEnd: isEnabled && widget.onHold != null ? _handleLongPressEnd : null,
      onLongPressCancel: isEnabled && widget.onHold != null ? _handleLongPressCancel : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
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
