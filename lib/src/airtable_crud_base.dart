import 'dart:convert';

import 'client/airtable_client.dart';
import 'client/request_builder.dart';
import 'config/airtable_config.dart';
import 'constants/airtable_constants.dart';
import 'errors/airtable_exception.dart';
import 'models/airtable_record.dart';
import 'models/delete_result.dart';

/// A class that provides CRUD operations for Airtable.
///
/// This class includes methods to fetch, create, update, and delete records
/// in an Airtable base. It also supports bulk creation of records and
/// advanced features like retry logic and custom configuration.
///
/// As of v1.3.0, this class uses an improved architecture with better
/// error handling, configuration management, and HTTP client abstraction.
class AirtableCrud {
  /// The API key for accessing the Airtable API.
  final String apiKey;

  /// The Base ID of your Airtable base.
  final String baseId;

  /// The configuration for this instance.
  final AirtableConfig _config;

  /// The HTTP client for making API requests.
  final AirtableClient _client;

  /// The request builder for constructing URLs.
  final RequestBuilder _requestBuilder;

  /// Creates an [AirtableCrud] instance with advanced configuration.
  ///
  /// This is the recommended constructor for v1.3.0 and later.
  /// It allows full control over timeouts, retries, and other options.
  ///
  /// Example:
  /// ```dart
  /// final config = AirtableConfig(
  ///   apiKey: 'your_api_key',
  ///   baseId: 'your_base_id',
  ///   timeout: Duration(seconds: 60),
  ///   maxRetries: 5,
  /// );
  /// final crud = AirtableCrud.withConfig(config);
  /// ```
  AirtableCrud.withConfig(AirtableConfig config)
      : apiKey = config.apiKey,
        baseId = config.baseId,
        _config = config,
        _client = AirtableClient(config),
        _requestBuilder = RequestBuilder(
          endpoint: config.endpoint,
          baseId: config.baseId,
        );

  /// Creates a simple [AirtableCrud] instance with just API key and base ID.
  ///
  /// This constructor uses default values for all configuration options.
  /// For backward compatibility with v1.2.x and earlier.
  ///
  /// Example:
  /// ```dart
  /// final crud = AirtableCrud('your_api_key', 'your_base_id');
  /// ```
  @Deprecated('Use AirtableCrud.withConfig() for more configuration options. '
      'This constructor will remain supported but offers limited functionality. '
      'Deprecated since version 1.3.0.')
  AirtableCrud(this.apiKey, this.baseId)
      : _config = AirtableConfig.simple(apiKey: apiKey, baseId: baseId),
        _client = AirtableClient(
          AirtableConfig.simple(apiKey: apiKey, baseId: baseId),
        ),
        _requestBuilder = RequestBuilder(
          endpoint: AirtableConstants.defaultEndpoint,
          baseId: baseId,
        );

  /// Fetches records from the specified [tableName].
  ///
  /// This unified method supports all fetching operations including filtering.
  ///
  /// Parameters:
  /// - [tableName]: The name of the table to fetch records from
  /// - [view]: Optional view name (defaults to config default or 'Grid view')
  /// - [fields]: Optional list of field names to include in response
  /// - [filter]: Optional filterByFormula string for filtering records
  /// - [paginate]: Whether to fetch all pages (default: true)
  /// - [maxRecords]: Optional maximum number of records to return
  ///
  /// Returns a [Future] that resolves to a list of [AirtableRecord].
  ///
  /// Throws an [AirtableException] if the request fails.
  ///
  /// Example:
  /// ```dart
  /// // Fetch all records
  /// final all = await crud.fetchRecords('Users');
  ///
  /// // Fetch with filter
  /// final active = await crud.fetchRecords(
  ///   'Users',
  ///   filter: "AND({status} = 'active')",
  /// );
  ///
  /// // Fetch specific fields
  /// final names = await crud.fetchRecords(
  ///   'Users',
  ///   fields: ['name', 'email'],
  /// );
  /// ```
  Future<List<AirtableRecord>> fetchRecords(
    String tableName, {
    String? view,
    List<String>? fields,
    String? filter,
    bool paginate = true,
    int? maxRecords,
  }) async {
    final List<AirtableRecord> allRecords = [];
    String? offset;

    // Use config default view if none specified
    final effectiveView =
        view ?? _config.defaultView ?? AirtableConstants.defaultView;

    do {
      // Build the URL with query parameters
      final uri = _requestBuilder.buildFetchUrl(
        tableName: tableName,
        view: effectiveView,
        fields: fields,
        filter: filter,
        offset: offset,
        maxRecords: maxRecords,
      );

      // Make the request
      final response = await _client.get(uri);

      // Parse the response
      final jsonData = jsonDecode(response.body);
      allRecords.addAll(
        (jsonData['records'] as List)
            .map((recordJson) => AirtableRecord.fromJson(recordJson))
            .toList(),
      );

      // Get pagination offset
      offset = jsonData['offset'] as String?;

      // Break if not paginating or no more pages
      if (!paginate) break;
    } while (offset != null);

    return allRecords;
  }

  /// DEPRECATED: Fetches records with a filter.
  ///
  /// Use [fetchRecords] with the [filter] parameter instead.
  ///
  /// This method is maintained for backward compatibility and will be
  /// removed in version 2.0.0.
  @Deprecated('Use fetchRecords() with filter parameter instead: '
      'fetchRecords(tableName, filter: yourFormula). '
      'This method will be removed in version 2.0.0. '
      'Deprecated since version 1.3.0.')
  Future<List<AirtableRecord>> fetchRecordsWithFilter(
    String tableName,
    String filterByFormula, {
    bool paginate = true,
    String view = 'Grid view',
    List<String> fields = const [],
  }) async {
    // Redirect to new unified method
    return fetchRecords(
      tableName,
      view: view,
      fields: fields.isEmpty ? null : fields,
      filter: filterByFormula,
      paginate: paginate,
    );
  }

  /// Creates a new record in the specified [tableName].
  ///
  /// - [tableName]: The name of the table
  /// - [data]: A map containing field names and values for the new record
  ///
  /// Returns a [Future] that resolves to the created [AirtableRecord].
  ///
  /// Throws an [AirtableException] if the request fails.
  ///
  /// Example:
  /// ```dart
  /// final newRecord = await crud.createRecord(
  ///   'Users',
  ///   {'name': 'John Doe', 'email': 'john@example.com'},
  /// );
  /// print('Created record with ID: ${newRecord.id}');
  /// ```
  Future<AirtableRecord> createRecord(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    final recordWithoutId = {
      'fields': data,
      'typecast': true,
    };

    final uri = _requestBuilder.buildCreateUrl(tableName: tableName);
    final response = await _client.post(uri, recordWithoutId);

    return AirtableRecord.fromJson(jsonDecode(response.body));
  }

  /// Creates multiple records in bulk in the specified [tableName].
  ///
  /// This method automatically handles batching (Airtable limits to 10 records
  /// per request) and processes all records efficiently.
  ///
  /// - [tableName]: The name of the table
  /// - [dataList]: A list of maps, each containing field names and values
  ///
  /// Returns a [Future] that resolves to a list of created [AirtableRecord] instances.
  ///
  /// Throws an [AirtableException] if any request fails.
  ///
  /// Example:
  /// ```dart
  /// final dataList = [
  ///   {'name': 'User 1', 'email': 'user1@example.com'},
  ///   {'name': 'User 2', 'email': 'user2@example.com'},
  ///   // ... more records
  /// ];
  /// final created = await crud.createBulkRecords('Users', dataList);
  /// print('Created ${created.length} records');
  /// ```
  Future<List<AirtableRecord>> createBulkRecords(
    String tableName,
    List<Map<String, dynamic>> dataList,
  ) async {
    final List<AirtableRecord> createdRecords = [];
    const int batchSize = AirtableConstants.defaultBatchSize;

    // Process in batches of 10 (Airtable's limit)
    for (int i = 0; i < dataList.length; i += batchSize) {
      final batchData = dataList.sublist(
        i,
        i + batchSize > dataList.length ? dataList.length : i + batchSize,
      );

      final requestBody = {
        'records': batchData.map((data) => {'fields': data}).toList(),
        'typecast': true,
      };

      final uri = _requestBuilder.buildCreateUrl(tableName: tableName);
      final response = await _client.post(uri, requestBody);

      final jsonData = jsonDecode(response.body);
      createdRecords.addAll(
        (jsonData['records'] as List)
            .map((recordJson) => AirtableRecord.fromJson(recordJson))
            .toList(),
      );
    }

    return createdRecords;
  }

  /// Updates an existing record in the specified [tableName].
  ///
  /// As of v1.3.0, this method returns the updated record from the API response.
  ///
  /// - [tableName]: The name of the table
  /// - [record]: An [AirtableRecord] containing the updated fields
  ///
  /// Returns a [Future] that resolves to the updated [AirtableRecord].
  ///
  /// Throws an [AirtableException] if the request fails.
  ///
  /// Example:
  /// ```dart
  /// // Immutable update (recommended)
  /// final updated = record.updateField('status', 'completed');
  /// final result = await crud.updateRecord('Users', updated);
  ///
  /// // Or using copyWith
  /// final updated = record.copyWith(
  ///   fields: {...record.fields, 'status': 'completed'},
  /// );
  /// final result = await crud.updateRecord('Users', updated);
  /// ```
  Future<AirtableRecord> updateRecord(
    String tableName,
    AirtableRecord record,
  ) async {
    final body = {
      'fields': record.fields,
      'typecast': true,
    };

    final uri = _requestBuilder.buildUpdateUrl(
      tableName: tableName,
      recordId: record.id,
    );
    final response = await _client.patch(uri, body);

    return AirtableRecord.fromJson(jsonDecode(response.body));
  }

  /// Updates multiple records in bulk in the specified [tableName].
  ///
  /// This method automatically handles batching (Airtable limits to 10 records
  /// per request) and processes all records efficiently.
  ///
  /// - [tableName]: The name of the table
  /// - [records]: A list of [AirtableRecord] instances to update
  ///
  /// Returns a [Future] that resolves to a list of updated [AirtableRecord] instances.
  ///
  /// Throws an [AirtableException] if any request fails.
  ///
  /// Example:
  /// ```dart
  /// final updatedRecords = records.map(
  ///   (r) => r.updateField('status', 'processed'),
  /// ).toList();
  /// final results = await crud.updateBulkRecords('Users', updatedRecords);
  /// ```
  Future<List<AirtableRecord>> updateBulkRecords(
    String tableName,
    List<AirtableRecord> records,
  ) async {
    final List<AirtableRecord> updatedRecords = [];
    const int batchSize = AirtableConstants.defaultBatchSize;

    // Process in batches of 10 (Airtable's limit)
    for (int i = 0; i < records.length; i += batchSize) {
      final batchRecords = records.sublist(
        i,
        i + batchSize > records.length ? records.length : i + batchSize,
      );

      final requestBody = {
        'records': batchRecords
            .map((record) => {
                  'id': record.id,
                  'fields': record.fields,
                })
            .toList(),
        'typecast': true,
      };

      final uri = _requestBuilder.buildCreateUrl(tableName: tableName);
      final response = await _client.patch(uri, requestBody);

      final jsonData = jsonDecode(response.body);
      updatedRecords.addAll(
        (jsonData['records'] as List)
            .map((recordJson) => AirtableRecord.fromJson(recordJson))
            .toList(),
      );
    }

    return updatedRecords;
  }

  /// Deletes a record from the specified [tableName].
  ///
  /// As of v1.3.0, this method returns a [DeleteResult] with metadata about
  /// the deletion operation.
  ///
  /// - [tableName]: The name of the table
  /// - [id]: The ID of the record to delete
  ///
  /// Returns a [Future] that resolves to a [DeleteResult].
  ///
  /// Throws an [AirtableException] if the request fails.
  ///
  /// Example:
  /// ```dart
  /// final result = await crud.deleteRecord('Users', 'rec123abc');
  /// print('Deleted record ${result.id} at ${result.deletedAt}');
  /// ```
  Future<DeleteResult> deleteRecord(String tableName, String id) async {
    final uri = _requestBuilder.buildDeleteUrl(
      tableName: tableName,
      recordId: id,
    );
    final response = await _client.delete(uri);

    return DeleteResult.fromJson(jsonDecode(response.body));
  }

  /// Deletes multiple records in bulk from the specified [tableName].
  ///
  /// Note: Airtable's API requires individual DELETE requests for each record,
  /// so this method makes multiple requests. For large numbers of deletions,
  /// consider the rate limits.
  ///
  /// - [tableName]: The name of the table
  /// - [ids]: A list of record IDs to delete
  ///
  /// Returns a [Future] that resolves to a list of [DeleteResult] instances.
  ///
  /// Throws an [AirtableException] if any request fails.
  ///
  /// Example:
  /// ```dart
  /// final ids = ['rec123', 'rec456', 'rec789'];
  /// final results = await crud.deleteBulkRecords('Users', ids);
  /// print('Deleted ${results.length} records');
  /// ```
  Future<List<DeleteResult>> deleteBulkRecords(
    String tableName,
    List<String> ids,
  ) async {
    final List<DeleteResult> results = [];

    for (final id in ids) {
      try {
        final result = await deleteRecord(tableName, id);
        results.add(result);
      } catch (e) {
        // Log error but continue with other deletions
        if (_config.enableLogging) {
          print('[AirtableCrud] Failed to delete record $id: $e');
        }
        rethrow;
      }
    }

    return results;
  }

  /// Closes the HTTP client and releases resources.
  ///
  /// Call this when you're done with this [AirtableCrud] instance to
  /// free up system resources.
  void close() {
    _client.close();
  }
}
