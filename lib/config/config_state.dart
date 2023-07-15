import 'dart:convert';

import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_tracker/config/config_name.dart';

class ConfigState extends ChangeNotifier {
  Map<ConfigName, dynamic> config = {ConfigName.theme: "dark", ConfigName.seeAllMonths: true};
  String PERSIST_NAME = 'config';

  SharedPreferences? prefs;

  void loadFromLocalStorage(SharedPreferences prefs) {
    this.prefs = prefs;
    final String? configStr = prefs?.getString(PERSIST_NAME);
    if (configStr != null) {
      config = decode(configStr);
      notifyListeners();
    }
  }

  dynamic getConfig(ConfigName configName) {
    return config[configName];
  }

  void updateConfig(ConfigName configName, dynamic value) {
    config[configName] = value;

    if (prefs != null) {
      updateLocalStorage();
    }
    notifyListeners();
  }

  void updateLocalStorage() {
    Map<String, dynamic> encodableMap = Map.fromEntries(
      config.entries.map((entry) => MapEntry(entry.key.name, entry.value)),
    );
    prefs?.setString(PERSIST_NAME, json.encode(encodableMap));
  }

  Map<ConfigName, dynamic> decode(String configStr) {
    var decodedMap = json.decode(configStr) as Map<String, dynamic>;
    Map<ConfigName, dynamic> map = Map.fromEntries(
      decodedMap.entries.map((entry) {
        ConfigName configName = ConfigName.values.firstWhere((e) => e.name == entry.key);
        return MapEntry(configName, entry.value);
      }),
    );
    return map;
  }

// void toggleTheme() {
//   if (config['theme'] == "dark") {
//     config['theme'] = "light";
//   } else {
//     config['theme'] = "dark";
//   }
//   notifyListeners();
// }
}
