import 'package:airtable_crud/src/config/airtable_config.dart';
import 'package:airtable_crud/src/constants/airtable_constants.dart';
import 'package:test/test.dart';

void main() {
  group('AirtableConfig', () {
    const testApiKey = 'test_api_key_12345';
    const testBaseId = 'appTest12345';

    test('creates config with required parameters', () {
      final config = AirtableConfig(
        apiKey: testApiKey,
        baseId: testBaseId,
      );

      expect(config.apiKey, equals(testApiKey));
      expect(config.baseId, equals(testBaseId));
    });

    test('uses default values for optional parameters', () {
      final config = AirtableConfig(
        apiKey: testApiKey,
        baseId: testBaseId,
      );

      expect(config.endpoint, equals(AirtableConstants.defaultEndpoint));
      expect(config.timeout, equals(AirtableConstants.defaultTimeout));
      expect(config.maxRetries, equals(AirtableConstants.defaultMaxRetries));
      expect(config.retryDelay, equals(AirtableConstants.defaultRetryDelay));
      expect(config.enableLogging, equals(false));
      expect(config.defaultView, isNull);
    });

    test('allows custom values for optional parameters', () {
      const customEndpoint = 'https://custom.api.com/v0';
      const customTimeout = Duration(seconds: 60);
      const customMaxRetries = 5;
      const customRetryDelay = Duration(seconds: 2);
      const customDefaultView = 'Custom View';

      final config = AirtableConfig(
        apiKey: testApiKey,
        baseId: testBaseId,
        endpoint: customEndpoint,
        timeout: customTimeout,
        maxRetries: customMaxRetries,
        retryDelay: customRetryDelay,
        enableLogging: true,
        defaultView: customDefaultView,
      );

      expect(config.endpoint, equals(customEndpoint));
      expect(config.timeout, equals(customTimeout));
      expect(config.maxRetries, equals(customMaxRetries));
      expect(config.retryDelay, equals(customRetryDelay));
      expect(config.enableLogging, equals(true));
      expect(config.defaultView, equals(customDefaultView));
    });

    test('simple factory creates config with defaults', () {
      final config = AirtableConfig.simple(
        apiKey: testApiKey,
        baseId: testBaseId,
      );

      expect(config.apiKey, equals(testApiKey));
      expect(config.baseId, equals(testBaseId));
      expect(config.endpoint, equals(AirtableConstants.defaultEndpoint));
      expect(config.timeout, equals(AirtableConstants.defaultTimeout));
      expect(config.maxRetries, equals(AirtableConstants.defaultMaxRetries));
      expect(config.enableLogging, equals(false));
    });

    test('copyWith creates new config with updated values', () {
      final config = AirtableConfig(
        apiKey: testApiKey,
        baseId: testBaseId,
      );

      final updated = config.copyWith(
        timeout: Duration(seconds: 90),
        enableLogging: true,
      );

      expect(updated.apiKey, equals(testApiKey));
      expect(updated.baseId, equals(testBaseId));
      expect(updated.timeout, equals(Duration(seconds: 90)));
      expect(updated.enableLogging, equals(true));
      expect(updated.maxRetries, equals(config.maxRetries));
    });

    test('copyWith preserves original values when not specified', () {
      final config = AirtableConfig(
        apiKey: testApiKey,
        baseId: testBaseId,
        timeout: Duration(seconds: 60),
        enableLogging: true,
      );

      final updated = config.copyWith(
        maxRetries: 10,
      );

      expect(updated.timeout, equals(Duration(seconds: 60)));
      expect(updated.enableLogging, equals(true));
      expect(updated.maxRetries, equals(10));
    });

    test('toString returns readable representation', () {
      final config = AirtableConfig(
        apiKey: testApiKey,
        baseId: testBaseId,
      );

      final str = config.toString();
      expect(str, contains(testBaseId));
      expect(str, contains('AirtableConfig'));
      expect(
          str, isNot(contains(testApiKey))); // API key shouldn't be in toString
    });
  });
}
