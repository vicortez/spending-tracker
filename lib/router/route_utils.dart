class AppRouteConstants {
  static const String homePath = '/';
  static const String categoriesPath = '/categories';
  static const String reportsPath = '/reports';
  static const String settingsPath = '/settings';
  static const String aboutPath = '/about';
  static const String allExpensesPath = '/all-expenses';
  static const String editExpensePath = 'edit/:id';

  static const Map<int, String> tabIndexToPath = {
    0: homePath,
    1: categoriesPath,
    2: reportsPath,
    3: settingsPath,
    4: aboutPath,
  };

  static int getTabIndex(String location) {
    if (location.startsWith(categoriesPath)) return 1;
    if (location.startsWith(reportsPath)) return 2;
    if (location.startsWith(settingsPath)) return 3;
    if (location.startsWith(aboutPath)) return 4;
    return 0;
  }
}
