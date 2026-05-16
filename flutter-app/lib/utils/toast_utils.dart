import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

/// Shows a toast message at the top of the screen with a countdown indicator and close button
void showToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 4),
  FlushbarPosition position = FlushbarPosition.TOP,
}) {
  // Create overlay entry with animation controller
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => _ToastWidget(
      message: message,
      duration: duration,
      position: position,
      onDismiss: () {
        overlayEntry.remove();
      },
    ),
  );

  Overlay.of(context).insert(overlayEntry);
}

/// Internal stateful widget to manage the countdown animation controller
class _ToastWidget extends StatefulWidget {
  final String message;
  final Duration duration;
  final FlushbarPosition position;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.duration,
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDisposed = false;
  Flushbar? _flushbar;

  @override
  void initState() {
    super.initState();
    // Create controller that fills up from 0.0 to 1.0
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 0.0, // Start empty
    );

    // Start fill-up animation
    _controller.animateTo(1.0, duration: widget.duration, curve: Curves.linear);

    // Show the flushbar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _flushbar = Flushbar(
          message: widget.message,
          messageColor: Colors.black,
          duration: widget.duration,
          flushbarPosition: widget.position,
          margin: const EdgeInsets.only(bottom: 0, top: 0, left: 0, right: 0),
          borderRadius: BorderRadius.circular(0),
          backgroundColor: Colors.white,
          showProgressIndicator: true,
          progressIndicatorController: _controller,
          progressIndicatorBackgroundColor: Colors.grey[300],
          progressIndicatorValueColor: const AlwaysStoppedAnimation<Color>(
            Colors.cyan,
          ),
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
          isDismissible: true,
          animationDuration: const Duration(milliseconds: 150),
          forwardAnimationCurve: Curves.easeOut,
          reverseAnimationCurve: Curves.easeIn,
          mainButton: TextButton(
            onPressed: () {
              _flushbar?.dismiss();
            },
            child: const Icon(
              Icons.close,
              color: Colors.black,
              size: 20,
            ),
          ),
          onStatusChanged: (status) {
            if (status == FlushbarStatus.DISMISSED) {
              widget.onDismiss();
            }
          },
        );
        _flushbar!.show(context);
      }
    });
  }

  @override
  void dispose() {
    // Wrap in try-catch since Flushbar may have already disposed the controller
    if (!_isDisposed) {
      try {
        _controller.dispose();
        _isDisposed = true;
      } catch (e) {
        // Controller already disposed by Flushbar, ignore
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return an empty container as the actual toast is shown by Flushbar
    return const SizedBox.shrink();
  }
}
