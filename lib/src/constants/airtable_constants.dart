/// Constants used throughout the Airtable CRUD package.
///
/// This class contains HTTP status codes, default values, and other
/// constants to ensure consistency across the package.
class AirtableConstants {
  // Prevent instantiation
  AirtableConstants._();

  /// Default Airtable API endpoint
  static const String defaultEndpoint = 'https://api.airtable.com/v0';

  // HTTP Status Codes
  /// Success response code
  static const int statusOk = 200;

  /// Created response code (successful creation)
  static const int statusCreated = 201;

  /// Bad request error code
  static const int statusBadRequest = 400;

  /// Unauthorized error code (invalid API key)
  static const int statusUnauthorized = 401;

  /// Forbidden error code (insufficient permissions)
  static const int statusForbidden = 403;

  /// Not found error code
  static const int statusNotFound = 404;

  /// Unprocessable entity error code (validation error)
  static const int statusUnprocessableEntity = 422;

  /// Too many requests error code (rate limit exceeded)
  static const int statusTooManyRequests = 429;

  /// Internal server error code
  static const int statusInternalServerError = 500;

  // Default Values
  /// Default view name in Airtable
  static const String defaultView = 'Grid view';

  /// Maximum number of records per batch operation (Airtable limit)
  static const int defaultBatchSize = 10;

  /// Default number of retry attempts for failed requests
  static const int defaultMaxRetries = 3;

  /// Default timeout duration for HTTP requests
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Default delay between retry attempts
  static const Duration defaultRetryDelay = Duration(seconds: 1);

  // HTTP Headers
  /// Authorization header key
  static const String headerAuthorization = 'Authorization';

  /// Content-Type header key
  static const String headerContentType = 'Content-Type';

  /// JSON content type value
  static const String contentTypeJson = 'application/json';

  /// Bearer token prefix for authorization
  static const String bearerPrefix = 'Bearer';
}
