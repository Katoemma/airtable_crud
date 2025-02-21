import 'dart:convert';
import 'package:airtable_crud/src/errors/airtable_exception.dart';
import 'package:http/http.dart' as http;
import 'models/airtable_record.dart';

/// A class that provides CRUD operations for Airtable.
///
/// This class includes methods to fetch, create, update, and delete records
/// in an Airtable base. It also supports bulk creation of records.
class AirtableCrud {
  /// The API key for accessing the Airtable API.
  final String apiKey;

  /// The Base ID of your Airtable base.
  final String baseId;

  /// Constructs an instance of [AirtableCrud] with the given [apiKey] and [baseId].
  AirtableCrud(this.apiKey, this.baseId);

  final String _endpoint = 'https://api.airtable.com/v0';

  /// Fetches records from the specified [tableName].
  ///
  /// - [paginate]: If true (default), fetches all pages of records.
  /// - [view]: The view in Airtable from which to fetch records (default is 'Grid view').
  /// - [fields]: A list of field names to include in the response.
  ///
  /// Returns a [Future] that resolves to a list of [AirtableRecord].
  ///
  /// Throws an [AirtableException] if the request fails.
  Future<List<AirtableRecord>> fetchRecords(
    String tableName, {
    bool paginate = true,
    String view = 'Grid view',
    List<String> fields = const [],
  }) async {
    List<AirtableRecord> allRecords = [];
    String? offset;

    do {
      List<String> queryParts = ['view=${Uri.encodeComponent(view)}'];
      if (offset != null) queryParts.add('offset=$offset');
      if (fields.isNotEmpty) {
        queryParts.addAll(
            fields.map((field) => 'fields[]=${Uri.encodeComponent(field)}'));
      }

      String queryString = queryParts.join('&');
      Uri uri = Uri.parse('$_endpoint/$baseId/$tableName?$queryString');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        allRecords.addAll((jsonData['records'] as List)
            .map((recordJson) => AirtableRecord.fromJson(recordJson))
            .toList());
        offset = jsonData['offset'];
      } else {
        final errorBody = jsonDecode(response.body);
        throw AirtableException(
          message: 'Failed to fetch records',
          details: errorBody['error']?['message'],
        );
      }

      if (!paginate) break;
    } while (offset != null);

    return allRecords;
  }

  /// Fetches records from the specified [tableName] using a filter formula.
  ///
  /// - [filterByFormula]: An Airtable formula to filter records.
  /// - [paginate]: If true (default), fetches all pages of records.
  /// - [view]: The view in Airtable from which to fetch records (default is 'Grid view').
  /// - [fields]: A list of field names to include in the response.
  ///
  /// Returns a [Future] that resolves to a list of [AirtableRecord].
  ///
  /// Throws an [AirtableException] if the request fails.
  Future<List<AirtableRecord>> fetchRecordsWithFilter(
    String tableName,
    String filterByFormula, {
    bool paginate = true,
    String view = 'Grid view',
    List<String> fields = const [],
  }) async {
    List<AirtableRecord> allRecords = [];
    String? offset;

    do {
      List<String> queryParts = ['view=${Uri.encodeComponent(view)}'];
      queryParts.add('filterByFormula=${Uri.encodeComponent(filterByFormula)}');
      if (offset != null) queryParts.add('offset=$offset');
      if (fields.isNotEmpty) {
        queryParts.addAll(
            fields.map((field) => 'fields[]=${Uri.encodeComponent(field)}'));
      }

      String queryString = queryParts.join('&');
      Uri uri = Uri.parse('$_endpoint/$baseId/$tableName?$queryString');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        allRecords.addAll((jsonData['records'] as List)
            .map((recordJson) => AirtableRecord.fromJson(recordJson))
            .toList());
        offset = jsonData['offset'];
      } else {
        final errorBody = jsonDecode(response.body);
        throw AirtableException(
          message: 'Failed to fetch records with filter',
          details: errorBody['error']?['message'],
        );
      }

      if (!paginate) break;
    } while (offset != null);

    return allRecords;
  }

  /// Creates a new record in the specified [tableName].
  ///
  /// - [data]: A map containing the field names and values for the new record.
  ///
  /// Returns a [Future] that resolves to the created [AirtableRecord].
  ///
  /// Throws an [AirtableException] if the request fails.
  Future<AirtableRecord> createRecord(
      String tableName, Map<String, dynamic> data) async {
    final recordWithoutId = {'fields': data, 'typecast': true};

    final response = await http.post(
      Uri.parse('$_endpoint/$baseId/$tableName'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(recordWithoutId),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AirtableRecord.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw AirtableException(
        message: 'Failed to create record',
        details: errorBody['error']?['message'],
      );
    }
  }

  /// Creates multiple records in bulk in the specified [tableName].
  ///
  /// - [dataList]: A list of maps, each containing field names and values for a record.
  ///
  /// Returns a [Future] that resolves to a list of created [AirtableRecord] instances.
  ///
  /// Throws an [AirtableException] if the request fails.
  Future<List<AirtableRecord>> createBulkRecords(
      String tableName, List<Map<String, dynamic>> dataList) async {
    List<AirtableRecord> createdRecords = [];
    const int batchSize = 10;

    for (int i = 0; i < dataList.length; i += batchSize) {
      final batchData = dataList.sublist(
        i,
        i + batchSize > dataList.length ? dataList.length : i + batchSize,
      );

      final requestBody = {
        'records': batchData.map((data) => {'fields': data}).toList(),
        'typecast': true,
      };

      final response = await http.post(
        Uri.parse('$_endpoint/$baseId/$tableName'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        createdRecords.addAll((jsonData['records'] as List)
            .map((recordJson) => AirtableRecord.fromJson(recordJson))
            .toList());
      } else {
        final errorBody = jsonDecode(response.body);
        throw AirtableException(
          message: 'Failed to create records',
          details: errorBody['error']?['message'],
        );
      }
    }

    return createdRecords;
  }

  /// Updates an existing record in the specified [tableName].
  ///
  /// - [record]: An instance of [AirtableRecord] containing the updated fields.
  ///
  /// Throws an [AirtableException] if the request fails.
  Future<void> updateRecord(String tableName, AirtableRecord record) async {
    // Ensure the fields are nested within 'fields' and include 'typecast': true
    final Map<String, dynamic> body = {
      'fields': record.fields,
      'typecast': true,
    };

    final response = await http.patch(
      Uri.parse('$_endpoint/$baseId/$tableName/${record.id}'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body), // Use the nested 'fields' format
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw AirtableException(
        message: 'Failed to update record',
        details: errorBody['error']?['message'],
      );
    }
  }

  /// Deletes a record from the specified [tableName].
  ///
  /// - [id]: The ID of the record to delete.
  ///
  /// Throws an [AirtableException] if the request fails.
  Future<void> deleteRecord(String tableName, String id) async {
    final response = await http.delete(
      Uri.parse('$_endpoint/$baseId/$tableName/$id'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw AirtableException(
        message: 'Failed to delete record',
        details: errorBody['error']?['message'],
      );
    }
  }
}
