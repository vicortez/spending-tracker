import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/settings/settings_provider.dart';
import 'package:spending_tracker/services/backup_service.dart';

void main() {
  group('SettingsProvider - getBackupsData', () {
    late SharedPreferences prefs;
    late SettingsProvider settingsProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      settingsProvider = SettingsProvider();
      await settingsProvider.loadFromLocalStorage(prefs);
    });

    test('should return null when no backups exist', () {
      final result = settingsProvider.getBackupsData();
      expect(result, isNull);
    });

    test('should return null when backup string is empty or invalid', () async {
      await prefs.setString(BackupService.BACKUP_KEY, '');
      expect(settingsProvider.getBackupsData(), isNull);

      await prefs.setString(BackupService.BACKUP_KEY, 'invalid-json');
      expect(settingsProvider.getBackupsData(), isNull);
    });

    test('should return map of backups when valid data exists', () async {
      final backups = {
        '2024-01-01': {'data': 'old'},
        '2024-01-02': {'data': 'new'},
      };
      await prefs.setString(BackupService.BACKUP_KEY, json.encode(backups));

      final result = settingsProvider.getBackupsData();
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result['2024-01-02']['data'], 'new');
    });

    test('should only return latest 5 backups', () async {
      final backups = {
        '2024-01-01': {'v': 1},
        '2024-01-02': {'v': 2},
        '2024-01-03': {'v': 3},
        '2024-01-04': {'v': 4},
        '2024-01-05': {'v': 5},
        '2024-01-06': {'v': 6},
      };
      await prefs.setString(BackupService.BACKUP_KEY, json.encode(backups));

      final result = settingsProvider.getBackupsData();
      expect(result, isNotNull);
      expect(result!.length, 5);
      expect(result.containsKey('2024-01-01'), false);
      expect(result.containsKey('2024-01-06'), true);
    });
  });
}
