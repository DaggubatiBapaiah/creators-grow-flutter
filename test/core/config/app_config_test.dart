import 'package:flutter_test/flutter_test.dart';
import 'package:creators_grow/core/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    test('apiBaseUrl returns default URL on host platform', () {
      final baseUrl = AppConfig.apiBaseUrl;
      // On Windows development/test environment:
      expect(AppConfig.apiBaseUrl, 'http://127.0.0.1:3000');
    });
  });
}
