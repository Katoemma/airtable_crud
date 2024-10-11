class AirtableException implements Exception {
  final String message;
  final String? details;

  AirtableException({required this.message, this.details});

  @override
  String toString() {
    return 'AirtableException: $message ${details != null ? "- $details" : ""}';
  }
}
