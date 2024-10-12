import 'dart:convert';
import 'package:airtable_plugin/src/errors/airtable_exception.dart';
import 'package:http/http.dart' as http;
import 'models/airtable_record.dart';

class AirtableCrud {
  final String apiKey;
  final String baseId;

  AirtableCrud(this.apiKey, this.baseId);

  final String _endpoint = 'https://api.airtable.com/v0';

  Future<List<AirtableRecord>> fetchRecords(String tableName,
      {bool paginate = true, String view = 'Grid View'}) async {
    List<AirtableRecord> allRecords = [];
    String? offset;

    do {
      var uri = Uri.parse('$_endpoint/$baseId/$tableName').replace(
        queryParameters: {
          if (offset != null) 'offset': offset,
          'view': view, // Add view parameter
        },
      );

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
        // Get detailed error information from the response body
        final errorBody = jsonDecode(response.body);
        throw AirtableException(
          message: 'Failed to fetch records',
          details: errorBody['error']?['message'],
        );
      }

      if (!paginate) {
        break;
      }
    } while (offset != null);

    return allRecords;
  }

  Future<List<AirtableRecord>> fetchRecordsWithFilter(
      String tableName, String filterByFormula,
      {bool paginate = true, String view = 'Grid View'}) async {
    List<AirtableRecord> allRecords = [];
    String? offset;

    do {
      var uri = Uri.parse('$_endpoint/$baseId/$tableName').replace(
        queryParameters: {
          if (offset != null) 'offset': offset,
          'filterByFormula':
              filterByFormula, // No need for explicit encoding here
          'view': view, // Add view parameter
        },
      );

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

      if (!paginate) {
        break;
      }
    } while (offset != null);

    return allRecords;
  }

  Future<AirtableRecord> createRecord(
      String tableName, Map<String, dynamic> data) async {
    // Remove the 'id' field from the record before sending the request to create a new record
    final recordWithoutId = {'fields': data};

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
      // Extract error details
      final errorBody = jsonDecode(response.body);
      throw AirtableException(
        message: 'Failed to create record',
        details: errorBody['error']?['message'],
      );
    }
  }

  Future<void> updateRecord(String tableName, AirtableRecord record) async {
    // Ensure the fields are nested within 'fields'
    final Map<String, dynamic> body = {'fields': record.fields};

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
