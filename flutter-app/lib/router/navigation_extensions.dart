import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';

/// Extension methods on BuildContext for navigation with history tracking
extension NavigationExtensions on BuildContext {
  /// Push a new route and track it in navigation history
  ///
  /// This is a wrapper around [GoRouter.push] that automatically
  /// adds the route to the navigation history service
  Future<T?> pushWithHistory<T extends Object?>(
    String location, {
    Object? extra,
  }) {
    read<NavigationHistoryService>().push(location);
    return push(location, extra: extra);
  }

  /// Navigate to a route and track it in navigation history
  ///
  /// This is a wrapper around [GoRouter.go] that automatically
  /// adds the route to the navigation history service
  void goWithHistory(
    String location, {
    Object? extra,
  }) {
    read<NavigationHistoryService>().push(location);
    go(location, extra: extra);
  }
}
