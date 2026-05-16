import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/router/app_router.dart';
import 'package:spending_tracker/utils/toast_utils.dart';

class LoggerService {
  static const String LOG_KEY = 'error_logs';
  static SharedPreferences? _prefs;

  static Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
  }

  static void logError(String message) async {
    final timestamp = DateTime.now().toString().substring(0, 19);
    final entry = '[$timestamp] $message';

    if (_prefs != null) {
      final List<String> logs = _prefs!.getStringList(LOG_KEY) ?? [];
      logs.insert(0, entry); // Latest first
      // Keep last 100 entries
      if (logs.length > 100) {
        logs.removeRange(100, logs.length);
      }
      await _prefs!.setStringList(LOG_KEY, logs);
    }

    // Fire a toast
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      showToast(context, 'Error: $message');
    }
  }

  static List<String> getErrorLogs() {
    return _prefs?.getStringList(LOG_KEY) ?? [];
  }

  static Future<void> clearLogs() async {
    await _prefs?.remove(LOG_KEY);
  }
}
