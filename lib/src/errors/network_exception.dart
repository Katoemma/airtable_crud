import 'airtable_exception.dart';

/// Exception thrown when network-related errors occur.
///
/// This includes connection failures, timeouts, and other issues
/// that prevent successful communication with the Airtable API.
///
/// Examples:
/// - Connection timeout
/// - DNS resolution failure
/// - No internet connection
/// - Socket exceptions
class NetworkException extends AirtableException {
  /// Creates a [NetworkException].
  ///
  /// - [message]: Description of the network error
  /// - [details]: Optional additional context
  /// - [statusCode]: Optional HTTP status code if applicable
  NetworkException({
    required super.message,
    super.details,
    super.statusCode,
  });
}
