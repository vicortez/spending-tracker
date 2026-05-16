import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/category/category.dart';
import 'package:spending_tracker/repository/domain/domain.dart';
import 'package:spending_tracker/repository/expense/expense.dart';
import 'package:spending_tracker/router/app_router.dart';
import 'package:spending_tracker/utils/toast_utils.dart';

class BackupService {
  static const String BACKUP_KEY = 'daily_backups';

  Future<void> runDailyBackup(SharedPreferences prefs) async {
    try {
      final today = DateTime.now().toString().substring(0, 10);
      final String? existingBackupsStr = prefs.getString(BACKUP_KEY);
      Map<String, dynamic> backups = {};

      if (existingBackupsStr != null) {
        try {
          backups = json.decode(existingBackupsStr) as Map<String, dynamic>;
        } catch (e) {
          // If corrupt, start fresh
          backups = {};
        }
      }

      if (backups.containsKey(today)) {
        return; // Already backed up today
      }

      // Collect data
      final Map<String, dynamic> appData = {
        CategoryEntity.PERSIST_NAME: prefs.getString(CategoryEntity.PERSIST_NAME),
        ExpenseEntity.PERSIST_NAME: prefs.getString(ExpenseEntity.PERSIST_NAME),
        DomainEntity.PERSIST_NAME: prefs.getString(DomainEntity.PERSIST_NAME),
        'config': prefs.getString('config'),
      };

      // Add new backup
      backups[today] = appData;

      // Keep only latest 5
      final sortedDates = backups.keys.toList()..sort((a, b) => b.compareTo(a));
      if (sortedDates.length > 5) {
        for (int i = 5; i < sortedDates.length; i++) {
          backups.remove(sortedDates[i]);
        }
      }

      // Save
      await prefs.setString(BACKUP_KEY, json.encode(backups));
    } catch (e) {
      // Uncaught exception should not interfere with app behavior
      // We show a toast using the global navigator key context
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          showToast(context, 'Daily backup failed: $e');
        }
      });
    }
  }
}
