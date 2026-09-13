import 'dart:io';

class AppConfig {
  static String get apiBaseUrl {
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }
    try {
      if (Platform.isAndroid) {
        // Fallback to production if no dart-define is provided
        return 'https://api.creatorsgrow.co.in';
      }
    } catch (_) {
      // Fallback for non-IO platforms (e.g. Web)
    }
    return 'https://api.creatorsgrow.co.in';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
