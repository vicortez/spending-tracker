import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/services/backup_service.dart';

void main() {
  group('BackupService', () {
    late SharedPreferences prefs;
    late BackupService backupService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      backupService = BackupService();
    });

    test('should create a backup if none exists for today', () async {
      final today = DateTime.now().toString().substring(0, 10);

      await backupService.runDailyBackup(prefs);

      final backupStr = prefs.getString(BackupService.BACKUP_KEY);
      expect(backupStr, isNotNull);

      final backups = json.decode(backupStr!) as Map<String, dynamic>;
      expect(backups.containsKey(today), isTrue);
    });

    test('should only keep 5 latest backups', () async {
      Map<String, dynamic> oldBackups = {
        '2024-05-01': {},
        '2024-05-02': {},
        '2024-05-03': {},
        '2024-05-04': {},
        '2024-05-05': {},
      };
      await prefs.setString(BackupService.BACKUP_KEY, json.encode(oldBackups));

      await backupService.runDailyBackup(prefs);

      final backupStr = prefs.getString(BackupService.BACKUP_KEY);
      final backups = json.decode(backupStr!) as Map<String, dynamic>;

      expect(backups.length, 5);
      // The oldest '2024-05-01' should be gone
      expect(backups.containsKey('2024-05-01'), isFalse);
    });

    test('should not overwrite today\'s backup if already exists', () async {
      final today = DateTime.now().toString().substring(0, 10);
      final initialData = {
        today: {'data': 'initial'},
      };
      await prefs.setString(BackupService.BACKUP_KEY, json.encode(initialData));

      // Change some app data that would be backed up
      await prefs.setString('config', 'new_config');

      await backupService.runDailyBackup(prefs);

      final backupStr = prefs.getString(BackupService.BACKUP_KEY);
      final backups = json.decode(backupStr!) as Map<String, dynamic>;

      expect(backups[today]['config'], isNull); // Should still have initial data
    });
  });
}
