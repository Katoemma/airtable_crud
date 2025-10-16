import '../constants/airtable_constants.dart';

/// Configuration class for Airtable CRUD operations.
///
/// This class holds all configuration options including API credentials,
/// timeout settings, retry logic, and other customizable parameters.
class AirtableConfig {
  /// The API key for accessing the Airtable API.
  final String apiKey;

  /// The Base ID of your Airtable base.
  final String baseId;

  /// The Airtable API endpoint URL.
  ///
  /// Defaults to [AirtableConstants.defaultEndpoint].
  /// Can be overridden for testing or custom endpoints.
  final String endpoint;

  /// Timeout duration for HTTP requests.
  ///
  /// Defaults to [AirtableConstants.defaultTimeout] (30 seconds).
  final Duration timeout;

  /// Maximum number of retry attempts for failed requests.
  ///
  /// Defaults to [AirtableConstants.defaultMaxRetries] (3 attempts).
  final int maxRetries;

  /// Delay between retry attempts.
  ///
  /// Defaults to [AirtableConstants.defaultRetryDelay] (1 second).
  final Duration retryDelay;

  /// Whether to enable logging of requests and responses.
  ///
  /// Defaults to false. When enabled, logs HTTP requests and responses
  /// for debugging purposes.
  final bool enableLogging;

  /// Default view name to use when fetching records.
  ///
  /// If null, Airtable will use its default view.
  /// Can be overridden on individual fetch operations.
  final String? defaultView;

  /// Creates an [AirtableConfig] with the given settings.
  ///
  /// Required parameters:
  /// - [apiKey]: Your Airtable API key
  /// - [baseId]: Your Airtable base ID
  ///
  /// Optional parameters use sensible defaults from [AirtableConstants].
  const AirtableConfig({
    required this.apiKey,
    required this.baseId,
    this.endpoint = AirtableConstants.defaultEndpoint,
    this.timeout = AirtableConstants.defaultTimeout,
    this.maxRetries = AirtableConstants.defaultMaxRetries,
    this.retryDelay = AirtableConstants.defaultRetryDelay,
    this.enableLogging = false,
    this.defaultView,
  });

  /// Creates a simple [AirtableConfig] with just API key and base ID.
  ///
  /// This factory constructor uses all default values for optional parameters.
  /// Useful for quick setup and backward compatibility.
  factory AirtableConfig.simple({
    required String apiKey,
    required String baseId,
  }) {
    return AirtableConfig(
      apiKey: apiKey,
      baseId: baseId,
    );
  }

  /// Creates a copy of this config with some fields replaced.
  ///
  /// Useful for creating variations of a configuration without
  /// duplicating all parameters.
  AirtableConfig copyWith({
    String? apiKey,
    String? baseId,
    String? endpoint,
    Duration? timeout,
    int? maxRetries,
    Duration? retryDelay,
    bool? enableLogging,
    String? defaultView,
  }) {
    return AirtableConfig(
      apiKey: apiKey ?? this.apiKey,
      baseId: baseId ?? this.baseId,
      endpoint: endpoint ?? this.endpoint,
      timeout: timeout ?? this.timeout,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      enableLogging: enableLogging ?? this.enableLogging,
      defaultView: defaultView ?? this.defaultView,
    );
  }

  @override
  String toString() {
    return 'AirtableConfig(baseId: $baseId, endpoint: $endpoint, '
        'timeout: $timeout, maxRetries: $maxRetries, '
        'retryDelay: $retryDelay, enableLogging: $enableLogging)';
  }
}
