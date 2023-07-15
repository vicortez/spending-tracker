import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/models/focused_month/focused_month.dart';

class FocusedMonthState extends ChangeNotifier {
  FocusedMonth focusedMonth = FocusedMonth(month: DateTime.now());

  SharedPreferences? prefs;

  void loadFromLocalStorage(SharedPreferences prefs) {
    this.prefs = prefs;
    final String? focusedMonthStr = prefs?.getString(FocusedMonth.PERSIST_NAME);
    if (focusedMonthStr != null) {
      focusedMonth = FocusedMonth.decode(focusedMonthStr);
      notifyListeners();
    }
  }

  DateTime getMonth() => focusedMonth.month;

  void setFocusedMonth(DateTime month) {
    focusedMonth.month = month;

    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  void updateLocalStorage() {
    prefs?.setString(FocusedMonth.PERSIST_NAME, FocusedMonth.encode(focusedMonth));
  }
}
