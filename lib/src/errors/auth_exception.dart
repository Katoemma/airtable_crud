import 'airtable_exception.dart';

/// Exception thrown when authentication or authorization fails.
///
/// This typically occurs when:
/// - The API key is invalid or expired (401 Unauthorized)
/// - The API key doesn't have permission to access the resource (403 Forbidden)
/// - The base ID or table name is incorrect
///
/// Common HTTP status codes:
/// - 401: Unauthorized (invalid API key)
/// - 403: Forbidden (insufficient permissions)
class AuthException extends AirtableException {
  /// Creates an [AuthException].
  ///
  /// - [message]: Description of the authentication error
  /// - [details]: Optional additional context from the API response
  /// - [statusCode]: HTTP status code (typically 401 or 403)
  AuthException({
    required super.message,
    super.details,
    super.statusCode,
  });
}
