import 'airtable_exception.dart';

/// Exception thrown when Airtable's rate limits are exceeded.
///
/// Airtable enforces rate limits on API requests (typically 5 requests per second).
/// When this limit is exceeded, a 429 status code is returned.
///
/// Handling recommendations:
/// - Implement exponential backoff retry logic
/// - Use the [retryAfter] duration to wait before retrying
/// - Consider batching operations to reduce request frequency
class RateLimitException extends AirtableException {
  /// Suggested duration to wait before retrying the request.
  ///
  /// This is typically based on the 'Retry-After' header from the API response,
  /// or a default value if the header is not present.
  final Duration? retryAfter;

  /// Creates a [RateLimitException].
  ///
  /// - [message]: Description of the rate limit error
  /// - [details]: Optional additional context
  /// - [statusCode]: HTTP status code (429)
  /// - [retryAfter]: Optional duration to wait before retrying
  RateLimitException({
    required super.message,
    super.details,
    super.statusCode = 429,
    this.retryAfter,
  });

  @override
  String toString() {
    final base = super.toString();
    if (retryAfter != null) {
      return '$base - Retry after: ${retryAfter!.inSeconds}s';
    }
    return base;
  }
}
