import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/config/config_provider.dart';
import 'package:spending_tracker/services/backup_service.dart';

void main() {
  group('ConfigProvider - getBackupsData', () {
    late SharedPreferences prefs;
    late ConfigProvider configProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      configProvider = ConfigProvider();
      configProvider.loadFromLocalStorage(prefs);
    });

    test('should return null if no backups exist', () {
      final result = configProvider.getBackupsData();
      expect(result, isNull);
    });

    test('should return null if backups string is empty or invalid', () async {
      await prefs.setString(BackupService.BACKUP_KEY, '');
      expect(configProvider.getBackupsData(), isNull);

      await prefs.setString(BackupService.BACKUP_KEY, 'invalid-json');
      expect(configProvider.getBackupsData(), isNull);
    });

    test('should return all backups if there are 5 or fewer', () async {
      final backups = {
        '2024-05-01': {'data': '1'},
        '2024-05-02': {'data': '2'},
        '2024-05-03': {'data': '3'},
      };
      await prefs.setString(BackupService.BACKUP_KEY, json.encode(backups));

      final result = configProvider.getBackupsData();
      expect(result, isNotNull);
      expect(result!.length, 3);
      expect(result.containsKey('2024-05-01'), isTrue);
      expect(result.containsKey('2024-05-02'), isTrue);
      expect(result.containsKey('2024-05-03'), isTrue);
    });

    test('should return only the latest 5 backups', () async {
      final backups = {
        '2024-05-01': {'data': '1'},
        '2024-05-02': {'data': '2'},
        '2024-05-03': {'data': '3'},
        '2024-05-04': {'data': '4'},
        '2024-05-05': {'data': '5'},
        '2024-05-06': {'data': '6'},
      };
      await prefs.setString(BackupService.BACKUP_KEY, json.encode(backups));

      final result = configProvider.getBackupsData();
      expect(result, isNotNull);
      expect(result!.length, 5);
      // '2024-05-01' is the oldest and should be excluded
      expect(result.containsKey('2024-05-01'), isFalse);
      expect(result.containsKey('2024-05-06'), isTrue);
      expect(result.containsKey('2024-05-02'), isTrue);
    });
  });
}
