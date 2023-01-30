// Global state

import 'package:flutter/foundation.dart' hide Category;

// TODO connect with rest of the app
class ConfigState extends ChangeNotifier {
  var config = {'theme': "dark"};

  void toggleTheme() {
    if (config['theme'] == "dark") {
      config['theme'] = "light";
    } else {
      config['theme'] = "dark";
    }
    notifyListeners();
  }
}
