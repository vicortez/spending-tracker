import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/repository/services/api_service.dart';
import 'package:spending_tracker/repository/services/auth_models.dart';

class AuthProvider with ChangeNotifier {
  AuthResult? _authResult;
  final ApiService _apiService = ApiService();
  static const String _authKey = 'auth_data';

  AuthResult? get authResult => _authResult;
  bool get isAuthenticated => _authResult != null;
  PublicUser? get user => _authResult?.user;

  Future<void> loadFromLocalStorage(SharedPreferences prefs) async {
    final String? authData = prefs.getString(_authKey);
    if (authData != null) {
      try {
        _authResult = AuthResult.fromJson(json.decode(authData));
        _apiService.setToken(_authResult?.token);
        notifyListeners();
      } catch (e) {
        // Clear invalid data
        prefs.remove(_authKey);
      }
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      _authResult = await _apiService.signIn(username, password);
      _apiService.setToken(_authResult?.token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authKey, json.encode(_authResult!.toJson()));

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _authResult = null;
    _apiService.setToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);

    notifyListeners();
  }
}
