/// A custom exception class for handling errors related to Airtable operations.
///
/// The `AirtableException` class implements Dart's `Exception` interface and
/// provides additional context by including an error [message] and optional [details].
class AirtableException implements Exception {
  /// A brief description of the error that occurred.
  final String message;

  /// Additional details about the error, if available.
  final String? details;

  /// Creates an instance of [AirtableException] with the given [message] and optional [details].
  ///
  /// - [message]: A brief description of the error.
  /// - [details]: Optional additional information about the error.
  AirtableException({required this.message, this.details});

  /// Returns a string representation of the exception.
  ///
  /// This method overrides `toString` to provide a readable error message,
  /// including both the [message] and [details] if available.
  @override
  String toString() {
    return 'AirtableException: $message ${details != null ? "- $details" : ""}';
  }
}
