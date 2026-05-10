import 'package:flutter_test/flutter_test.dart';
import 'package:spending_tracker/services/navigation_history_service.dart';

void main() {
  group('NavigationHistoryService', () {
    late NavigationHistoryService service;

    setUp(() {
      service = NavigationHistoryService();
    });

    test('should start with empty history', () {
      expect(service.history, isEmpty);
      expect(service.hasHistory, isFalse);
      expect(service.currentLocation, isNull);
    });

    test('should push locations and track history', () {
      service.push('/');
      service.push('/categories');
      service.push('/reports');

      expect(service.history.length, 3);
      expect(service.history, ['/', '/categories', '/reports']);
      expect(service.currentLocation, '/reports');
      expect(service.hasHistory, isTrue);
    });

    test('should not add duplicate consecutive entries', () {
      service.push('/');
      service.push('/');
      service.push('/categories');
      service.push('/categories');

      expect(service.history.length, 2);
      expect(service.history, ['/', '/categories']);
    });

    test('should allow same location after different location', () {
      service.push('/');
      service.push('/categories');
      service.push('/');

      expect(service.history.length, 3);
      expect(service.history, ['/', '/categories', '/']);
    });

    test('should pop and return previous location', () {
      service.push('/');
      service.push('/categories');
      service.push('/reports');

      final previous = service.pop();

      expect(previous, '/categories');
      expect(service.currentLocation, '/categories');
      expect(service.history.length, 2);
      expect(service.hasHistory, isTrue);
    });

    test('should return null when popping with only one entry', () {
      service.push('/');

      final previous = service.pop();

      expect(previous, isNull);
      expect(service.history.length, 1);
      expect(service.hasHistory, isFalse);
    });

    test('should return null when popping empty history', () {
      final previous = service.pop();

      expect(previous, isNull);
      expect(service.history, isEmpty);
    });

    test('should clear all history', () {
      service.push('/');
      service.push('/categories');
      service.push('/reports');

      service.clear();

      expect(service.history, isEmpty);
      expect(service.hasHistory, isFalse);
      expect(service.currentLocation, isNull);
    });

    test('should get previous location without popping', () {
      service.push('/');
      service.push('/categories');
      service.push('/reports');

      final previous = service.getPrevious();

      expect(previous, '/categories');
      expect(service.history.length, 3); // Should not change
      expect(service.currentLocation, '/reports');
    });

    test('should return null for getPrevious with one entry', () {
      service.push('/');

      final previous = service.getPrevious();

      expect(previous, isNull);
    });

    test('should return null for getPrevious with empty history', () {
      final previous = service.getPrevious();

      expect(previous, isNull);
    });

    test('should notify listeners on push', () {
      int notifyCount = 0;
      service.addListener(() {
        notifyCount++;
      });

      service.push('/');
      service.push('/categories');

      expect(notifyCount, 2);
    });

    test('should not notify listeners on duplicate push', () {
      int notifyCount = 0;
      service.addListener(() {
        notifyCount++;
      });

      service.push('/');
      service.push('/'); // Duplicate

      expect(notifyCount, 1);
    });

    test('should notify listeners on pop', () {
      service.push('/');
      service.push('/categories');

      int notifyCount = 0;
      service.addListener(() {
        notifyCount++;
      });

      service.pop();

      expect(notifyCount, 1);
    });

    test('should notify listeners on clear', () {
      service.push('/');
      service.push('/categories');

      int notifyCount = 0;
      service.addListener(() {
        notifyCount++;
      });

      service.clear();

      expect(notifyCount, 1);
    });

    test('should maintain history order correctly', () {
      service.push('/');
      service.push('/categories');
      service.push('/reports');
      service.push('/settings');

      expect(service.history, ['/', '/categories', '/reports', '/settings']);

      service.pop();
      expect(service.history, ['/', '/categories', '/reports']);

      service.push('/about');
      expect(service.history, ['/', '/categories', '/reports', '/about']);
    });

    test('should handle complex navigation scenario', () {
      // Simulate: Home -> Categories -> Reports -> Categories -> Settings
      service.push('/');
      service.push('/categories');
      service.push('/reports');
      service.push('/categories'); // Back to categories (allowed, different from last)
      service.push('/settings');

      expect(service.history.length, 5);

      // Pop back through history
      expect(service.pop(), '/categories');
      expect(service.pop(), '/reports');
      expect(service.pop(), '/categories');
      expect(service.pop(), '/');

      // Should be at home with no more history
      expect(service.hasHistory, isFalse);
      expect(service.pop(), isNull);
    });
  });
}
