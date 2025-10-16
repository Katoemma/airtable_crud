import 'airtable_exception.dart';

/// Exception thrown when request data fails validation.
///
/// This occurs when the data sent to Airtable doesn't meet the
/// required format or constraints (HTTP 422 Unprocessable Entity).
///
/// Common causes:
/// - Invalid field types (e.g., string instead of number)
/// - Missing required fields
/// - Field names that don't exist in the table
/// - Data that violates field constraints (e.g., exceeded max length)
/// - Invalid formula syntax in filters
class ValidationException extends AirtableException {
  /// Creates a [ValidationException].
  ///
  /// - [message]: Description of the validation error
  /// - [details]: Optional additional context from API (often includes field names)
  /// - [statusCode]: HTTP status code (422)
  ValidationException({
    required super.message,
    super.details,
    super.statusCode = 422,
  });
}
