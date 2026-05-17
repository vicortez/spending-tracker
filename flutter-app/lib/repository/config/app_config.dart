class AppConfig {
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  static const String apiUrl = String.fromEnvironment('API_URL');
}
