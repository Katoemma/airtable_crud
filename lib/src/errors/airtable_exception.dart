/// Base exception class for all Airtable-related errors.
///
/// This abstract class serves as the foundation for a hierarchy of specific
/// exception types, allowing for more granular error handling in client code.
///
/// All Airtable exceptions include:
/// - A descriptive [message]
/// - Optional [details] providing additional context
/// - Optional HTTP [statusCode] when the error originated from an API response
abstract class AirtableException implements Exception {
  /// A brief description of the error that occurred.
  final String message;

  /// Additional details about the error, if available.
  final String? details;

  /// The HTTP status code associated with this error, if applicable.
  final int? statusCode;

  /// Creates an instance of [AirtableException].
  ///
  /// - [message]: A brief description of the error
  /// - [details]: Optional additional information about the error
  /// - [statusCode]: Optional HTTP status code from the API response
  AirtableException({
    required this.message,
    this.details,
    this.statusCode,
  });

  /// Returns a string representation of the exception.
  ///
  /// Includes the exception type, message, optional details, and status code.
  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (details != null) {
      buffer.write(' - $details');
    }
    if (statusCode != null) {
      buffer.write(' (HTTP $statusCode)');
    }
    return buffer.toString();
  }
}

/// General Airtable exception for errors that don't fit specific categories.
///
/// This is a concrete implementation of [AirtableException] that can be used
/// for general errors. For more specific error types, use the specialized
/// exception classes like [AuthException], [NetworkException], etc.
class GeneralAirtableException extends AirtableException {
  /// Creates a general Airtable exception.
  GeneralAirtableException({
    required super.message,
    super.details,
    super.statusCode,
  });
}
