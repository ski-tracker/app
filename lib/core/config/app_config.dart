/// App configuration - set to true for frontend-only mode
class AppConfig {
  /// Set this to true to use local storage instead of backend API
  static const bool useLocalStorage = true;
  
  /// Set this to false to use backend API
  static const bool useBackend = !useLocalStorage;
}

