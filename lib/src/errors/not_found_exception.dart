import 'airtable_exception.dart';

/// Exception thrown when a requested resource is not found.
///
/// This occurs when trying to access a resource that doesn't exist
/// (HTTP 404 Not Found).
///
/// Common causes:
/// - Invalid base ID
/// - Non-existent table name
/// - Record ID that doesn't exist or was deleted
/// - Incorrect API endpoint URL
class NotFoundException extends AirtableException {
  /// Creates a [NotFoundException].
  ///
  /// - [message]: Description of what was not found
  /// - [details]: Optional additional context
  /// - [statusCode]: HTTP status code (404)
  NotFoundException({
    required super.message,
    super.details,
    super.statusCode = 404,
  });
}
