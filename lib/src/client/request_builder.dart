/// Utility class for building Airtable API request URLs and query parameters.
///
/// This class centralizes the logic for constructing properly formatted
/// URLs with encoded query parameters for various Airtable operations.
class RequestBuilder {
  /// The base endpoint URL for the Airtable API.
  final String endpoint;

  /// The Airtable base ID.
  final String baseId;

  /// Creates a [RequestBuilder].
  ///
  /// - [endpoint]: The base Airtable API URL
  /// - [baseId]: The specific base ID to use
  const RequestBuilder({
    required this.endpoint,
    required this.baseId,
  });

  /// Builds a URL for fetching records from a table.
  ///
  /// Parameters:
  /// - [tableName]: The name of the table
  /// - [view]: Optional view name
  /// - [fields]: Optional list of field names to include
  /// - [filter]: Optional filterByFormula string
  /// - [offset]: Optional pagination offset
  /// - [maxRecords]: Optional maximum number of records to return
  ///
  /// Returns a properly formatted [Uri] with encoded query parameters.
  Uri buildFetchUrl({
    required String tableName,
    String? view,
    List<String>? fields,
    String? filter,
    String? offset,
    int? maxRecords,
  }) {
    final queryParts = <String>[];

    // Add view parameter
    if (view != null && view.isNotEmpty) {
      queryParts.add('view=${Uri.encodeComponent(view)}');
    }

    // Add filter formula
    if (filter != null && filter.isNotEmpty) {
      queryParts.add('filterByFormula=${Uri.encodeComponent(filter)}');
    }

    // Add pagination offset
    if (offset != null && offset.isNotEmpty) {
      queryParts.add('offset=$offset');
    }

    // Add max records limit
    if (maxRecords != null && maxRecords > 0) {
      queryParts.add('maxRecords=$maxRecords');
    }

    // Add fields (multiple fields[] parameters)
    if (fields != null && fields.isNotEmpty) {
      queryParts.addAll(
        fields.map((field) => 'fields[]=${Uri.encodeComponent(field)}'),
      );
    }

    // Build the complete URL
    final queryString = queryParts.isEmpty ? '' : '?${queryParts.join('&')}';
    final encodedTableName = Uri.encodeComponent(tableName);
    return Uri.parse('$endpoint/$baseId/$encodedTableName$queryString');
  }

  /// Builds a URL for creating records in a table.
  ///
  /// Parameters:
  /// - [tableName]: The name of the table
  ///
  /// Returns a [Uri] for the create records endpoint.
  Uri buildCreateUrl({required String tableName}) {
    final encodedTableName = Uri.encodeComponent(tableName);
    return Uri.parse('$endpoint/$baseId/$encodedTableName');
  }

  /// Builds a URL for updating a specific record.
  ///
  /// Parameters:
  /// - [tableName]: The name of the table
  /// - [recordId]: The ID of the record to update
  ///
  /// Returns a [Uri] for the update record endpoint.
  Uri buildUpdateUrl({
    required String tableName,
    required String recordId,
  }) {
    final encodedTableName = Uri.encodeComponent(tableName);
    return Uri.parse('$endpoint/$baseId/$encodedTableName/$recordId');
  }

  /// Builds a URL for deleting a specific record.
  ///
  /// Parameters:
  /// - [tableName]: The name of the table
  /// - [recordId]: The ID of the record to delete
  ///
  /// Returns a [Uri] for the delete record endpoint.
  Uri buildDeleteUrl({
    required String tableName,
    required String recordId,
  }) {
    final encodedTableName = Uri.encodeComponent(tableName);
    return Uri.parse('$endpoint/$baseId/$encodedTableName/$recordId');
  }
}
